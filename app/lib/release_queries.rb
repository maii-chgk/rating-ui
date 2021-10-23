module ReleaseQueries
  include Cacheable

  ReleaseTeam = Struct.new(:team_id, :name, :city,
                           :place, :previous_place, :rating, :rating_change,
                           keyword_init: true)

  ReleasePlayer = Struct.new(:player_id, :name, :city,
                             :place, :rating, :rating_change,
                             keyword_init: true)

  def teams_for_release(release_id:, top_place:, bottom_place:)
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
      where r.place >= $2 and r.place <= $3
      order by r.place;
    SQL

    exec_query(query: sql,
               params: [release_id, top_place, bottom_place],
               cache_key: "#{name}/#{release_id}/#{top_place}-#{bottom_place}",
               result_class: ReleaseTeam)
  end

  def teams_for_release_api(release_id:, limit:, offset:)
    sql = <<~SQL
      select rank() over (order by rating desc) as place, team_id, rating, rating_change
      from #{name}.team_rating
      where release_id = $1
      order by place
      limit $2
      offset $3;
    SQL

    exec_query_for_hash_array(query: sql,
               params: [release_id, limit, offset],
               cache_key: "#{name}/api/#{release_id}/#{limit}-#{offset}")
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

    exec_query_for_hash(query: sql,
                        params: [release_id],
                        cache_key: "#{name}/tournaments_in_release_by_team/#{release_id}",
                        group_by: "team_id")
  end

  def all_releases
    sql = <<~SQL
      select date, id
      from #{name}.release
      order by date desc
    SQL

    exec_query_for_hash_array(query: sql, cache_key: "#{name}/all_releases")
  end

  def latest_release_id
    sql = <<~SQL
      select id
      from #{name}.release
      where date = (select max(date) as max_date from #{name}.release)
    SQL

    exec_query_for_single_value(query: sql, cache_key: "#{name}/latest_release")
  end

  def count_all_teams_in_release(release_id:)
    sql = <<~SQL
      select count(*)
      from #{name}.team_rating
      where release_id = $1
    SQL

    exec_query_for_single_value(query: sql,
                                params: [release_id],
                                cache_key: "#{name}/#{release_id}/count",
                                default_value: 0)
  end

  def players_for_release(release_id:, top_place:, bottom_place:)
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

    exec_query(query: sql,
               params: [release_id, top_place, bottom_place],
               cache_key: "#{name}/#{release_id}/players/#{top_place}-#{bottom_place}",
               result_class: ReleasePlayer)
  end

  def player_ratings_for_release(release_id:)
    sql = <<~SQL
      select player_id, tournament_id, 
          cur_score as current_rating, initial_score as initial_rating
      from #{name}.player_rating_by_tournament
      where release_id = $1
    SQL

    exec_query_for_hash(query: sql,
                        params: [release_id],
                        cache_key: "#{name}/player_ratings_for_release/#{release_id}",
                        group_by: "player_id")
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

    exec_query_for_hash_array(query: sql,
                              params: [release_id, limit, offset],
                              cache_key: "#{name}/api/#{release_id}/players/#{limit}-#{offset}")
  end

  def count_all_players_in_release(release_id:)
    sql = <<~SQL
      select count(*)
      from #{name}.player_rating
      where release_id = $1
    SQL

    exec_query_for_single_value(query: sql,
                                params: [release_id],
                                cache_key: "#{name}#{release_id}/players/count",
                                default_value: 0)
  end
end
