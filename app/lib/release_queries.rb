module ReleaseQueries
  include Cacheable

  ReleaseTeam = Struct.new(:team_id, :name, :city,
                           :place, :previous_place, :rating, :rating_change,
                           keyword_init: true)

  ReleasePlayer = Struct.new(:player_id, :name, :city,
                             :place, :rating, :rating_change,
                             keyword_init: true)

  def teams_for_release(release_id:, from:, to:, team_name: nil, city: nil)
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
      left join public.teams t on r.team_id = t.id
      left join public.towns town on town.id = t.town_id
      left join ranked_prev_release as prev using (team_id)
      where t.title ilike $4 and town.title ilike $5
      order by r.place
      limit $2
      offset $3;
    SQL

    limit = to - from + 1
    offset = from - 1
    exec_query(query: sql, params: [release_id, limit, offset, "%#{team_name}%", "%#{city}%"], result_class: ReleaseTeam, cache: true)
  end

  def teams_for_release_api(release_id:, limit:, offset:)
    sql = <<~SQL
      with ordered as (
          select id, row_number() over (order by date)
          from #{name}.release
      ),
      releases as (
          select o1.id as release_id, o2.id as prev_release_id
          from ordered o1
          left join ordered o2 on o1.row_number = o2.row_number + 1
      )
      select r.*, prev.place as previous_place, r.place - prev.place as place_change
      from #{name}.team_ranking r
      left join #{name}.team_ranking prev
        on r.team_id = prev.team_id
          and prev.release_id = (select prev_release_id from releases where release_id = $1)
      where r.release_id = $1
      order by row_number() over (order by r.rating desc)
      limit $2
      offset $3;
    SQL

    exec_query_for_hash_array(query: sql, params: [release_id, limit, offset])
  end

  def tournaments_in_release_by_team(release_id:)
    sql = <<~SQL
      select t.id as tournament_id, tr.team_id, tr.rating, tr.rating_change, t.maii_rating as in_rating
      from #{name}.tournament_result tr
      left join public.tournaments t on tr.tournament_id = t.id
      left join #{name}.release rel
        on t.end_datetime < rel.date + interval '24 hours' and t.end_datetime >= rel.date - interval '6 days'
      where rel.id = $1
    SQL

    exec_query_for_hash(query: sql, params: [release_id], group_by: "team_id")
  end

  def tournaments_by_release
    sql = <<~SQL
      select t.id as id, t.maii_rating as in_rating, rel.id as release_id
      from public.tournaments t
      join #{name}.release rel
        on t.end_datetime < rel.date + interval '24 hours' and t.end_datetime >= rel.date - interval '6 days'
    SQL

    exec_query_for_hash(query: sql, group_by: "release_id")
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
          where r.date < now()
          group by r.id, r.date
      )

        select id
        from #{name}.release
        where date = (select max(date) from team_count where count > 0)
    SQL

    exec_query_for_single_value(query: sql)
  end

  def count_all_teams_in_release(release_id:, team_name: nil, city: nil)
    sql = <<~SQL
      select count(*)
      from #{name}.team_rating tr
      left join public.teams t on t.id = tr.team_id
      left join public.towns town on town.id = t.town_id
      where tr.release_id = $1
          and t.title ilike $2 
          and town.title ilike $3
    SQL

    exec_query_for_single_value(query: sql, params: [release_id, "%#{team_name}%", "%#{city}%"], default_value: 0)
  end

  def players_for_release(release_id:, from:, to:, first_name: nil, last_name: nil)
    sql = <<~SQL
      with ranked as (
        select rank() over (order by rating desc) as place, player_id, rating, rating_change
        from #{name}.player_rating
        where release_id = $1
      )
      
      select r.*, p.first_name || '&nbsp;' || last_name as name
      from ranked r
      left join public.players p on p.id = r.player_id
      where p.first_name ilike $4 and p.last_name ilike $5
      order by r.place
      limit $2
      offset $3;
    SQL

    limit = to - from + 1
    offset = from - 1
    exec_query(query: sql,
               params: [release_id, limit, offset, "%#{first_name}%", "%#{last_name}%"],
               result_class: ReleasePlayer)
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
      with ordered as (
          select id, row_number() over (order by date)
          from #{name}.release
      ),
      releases as (
          select o1.id as release_id, o2.id as prev_release_id
          from ordered o1
          left join ordered o2 on o1.row_number = o2.row_number + 1
      )

      select r.*, prev.place as previous_place, r.place - prev.place as place_change
      from #{name}.player_ranking r
      left join #{name}.player_ranking prev
        on r.player_id = prev.player_id
            and prev.release_id = (select prev_release_id from releases where release_id = $1)
      where r.release_id = $1 
      order by row_number() over (order by r.rating desc)
      limit $2
      offset $3;
    SQL

    exec_query_for_hash_array(query: sql, params: [release_id, limit, offset], cache: true)
  end

  def count_all_players_in_release(release_id:, first_name: nil, last_name: nil)
    sql = <<~SQL
      select count(*)
      from #{name}.player_rating pr
      left join public.players p on p.id = pr.player_id 
      where release_id = $1
        and p.first_name ilike $2
        and p.last_name ilike $3
    SQL

    exec_query_for_single_value(query: sql,
                                params: [release_id, "%#{first_name}%", "%#{last_name}%"],
                                default_value: 0)
  end
end
