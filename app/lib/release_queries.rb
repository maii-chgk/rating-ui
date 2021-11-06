module ReleaseQueries
  include Cacheable, Filterable

  ReleaseTeam = Struct.new(:team_id, :name, :city,
                           :place, :previous_place, :rating, :rating_change,
                           keyword_init: true)

  ReleasePlayer = Struct.new(:player_id, :name, :city,
                             :place, :rating, :rating_change,
                             keyword_init: true)

  def teams_for_release(release_id:, from:, to:, team_name: nil, city: nil)
    filter = build_filter({"t.title": team_name, "town.title": city})

    sql = <<~SQL
      with ordered as (
          select id, row_number() over (order by date)
          from #{name}.release
      ),
      releases as (
          select o1.id as release_id, o2.id as prev_release_id
          from ordered o1
          left join ordered o2 on o1.row_number = o2.row_number + 1
      ),
      ranked as (
          select rank() over (order by rating desc) as place, team_id, rating, rating_change
          from #{name}.team_rating
          where release_id = $1
      ),
      ranked_prev_release as (
          select rank() over (order by rating desc) as place, team_id
          from #{name}.team_rating
          where release_id = (select prev_release_id from releases where release_id = $1)
      )
      
      select r.*, t.title as name, town.title as city, prev.place as previous_place
      from ranked r
      left join public.rating_team t on r.team_id = t.id
      left join public.rating_town town on town.id = t.town_id
      left join ranked_prev_release as prev using (team_id)
      #{filter}
      order by r.place
      limit $2
      offset $3;
    SQL

    limit = to - from + 1
    offset = from - 1
    exec_query(query: sql, params: [release_id, limit, offset], result_class: ReleaseTeam)
  end

  def teams_for_release_api(release_id:, limit:, offset:)
    sql = <<~SQL
      select rank() over (order by rating desc) as place, team_id, 
          rating, rating_change, trb
      from #{name}.team_rating
      where release_id = $1
      order by place
      limit $2
      offset $3;
    SQL

    exec_query_for_hash_array(query: sql, params: [release_id, limit, offset])
  end

  def tournaments_in_release_by_team(release_id:)
    sql = <<~SQL
      select t.id as tournament_id, tr.team_id, tr.rating, tr.rating_change
      from #{name}.tournament_result tr
      left join public.rating_tournament t on tr.tournament_id = t.id
      left join #{name}.release rel
        on t.end_datetime < rel.date + interval '24 hours' and t.end_datetime >= rel.date - interval '6 days'
      where rel.id = $1
    SQL

    exec_query_for_hash(query: sql, params: [release_id], group_by: "team_id")
  end

  def all_releases
    sql = <<~SQL
      select date, id, updated_at
      from #{name}.release
      order by date desc
    SQL

    exec_query_for_hash_array(query: sql)
  end

  def latest_release_id
    sql = <<~SQL
        with team_count as (
          select r.id, r.date, count(tr.team_id)
          from #{name}.release r
          left join #{name}.team_rating tr on tr.release_id = r.id
          group by r.id, r.date
      )

        select id
        from #{name}.release
        where date = (select max(date) from team_count where count > 0)
    SQL

    exec_query_for_single_value(query: sql)
  end

  def count_all_teams_in_release(release_id:, city: nil)
    filters = build_filter({"tr.release_id": "$1", "town.title": city})
    sql = <<~SQL
      select count(*)
      from #{name}.team_rating tr
      left join public.rating_team t on t.id = tr.team_id
      left join public.rating_town town on town.id = t.town_id
      #{filters}
    SQL

    exec_query_for_single_value(query: sql, params: [release_id], default_value: 0)
  end

  def players_for_release(release_id:, from:, to:)
    sql = <<~SQL
      with ranked as (
        select rank() over (order by rating desc) as place, player_id, rating, rating_change
        from #{name}.player_rating
        where release_id = $1
      )
      
      select r.*, p.first_name || '&nbsp;' || last_name as name
      from ranked r
      left join public.rating_player p on p.id = r.player_id
      where r.place >= $2 and r.place <= $3
      order by r.place;
    SQL

    exec_query(query: sql, params: [release_id, from, to], result_class: ReleasePlayer)
  end

  def player_ratings_for_release(release_id:)
    sql = <<~SQL
      select player_id, tournament_id, 
          cur_score as current_rating, initial_score as initial_rating
      from #{name}.player_rating_by_tournament
      where release_id = $1
    SQL

    exec_query_for_hash(query: sql, params: [release_id], group_by: "player_id")
  end

  def players_for_release_api(release_id:, limit:, offset:)
    sql = <<~SQL
      select rank() over (order by rating desc) as place, player_id, rating, rating_change
      from #{name}.player_rating
      where release_id = $1
      order by place
      limit $2
      offset $3;
    SQL

    exec_query_for_hash_array(query: sql, params: [release_id, limit, offset])
  end

  def count_all_players_in_release(release_id:)
    sql = <<~SQL
      select count(*)
      from #{name}.player_rating
      where release_id = $1
    SQL

    exec_query_for_single_value(query: sql, params: [release_id], default_value: 0)
  end
end
