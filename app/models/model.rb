class Model < ApplicationRecord
  include Cacheable

  def teams_for_release(release_id:, top_place:, bottom_place:)
    sql = <<~SQL
      with ranked as (
          select rank() over (order by rating desc) as place, team_id, rating, rating_change
          from #{name}.team_rating
          where release_id = $1
      )
      
      select r.*, t.title as name, town.title as city
      from ranked r
      left join public.rating_team t on r.team_id = t.id
      left join public.rating_town town on town.id = t.town_id
      where r.place >= $2 and r.place <= $3
      order by r.place;
    SQL

    exec_query_with_cache(query: sql,
      params: [[nil, release_id], [nil, top_place], [nil, bottom_place]],
      cache_key: "#{name}/#{release_id}/#{top_place}-#{bottom_place}")
  end

  def all_releases
    sql = <<~SQL
      select date, id
      from #{name}.release
      order by date desc
    SQL

    exec_query_with_cache(query: sql, cache_key: "#{name}/all_releases").to_a
  end

  def latest_release_id
    sql = <<~SQL
      select id
      from #{name}.release
      where date = (select max(date) as max_date from #{name}.release)
    SQL

    exec_query_with_cache(query: sql, cache_key: "#{name}/latest_release").rows.first.first
  rescue NoMethodError
    -1
  end

  def count_all_teams_in_release(release_id:)
    sql = <<~SQL
      select count(*)
      from #{name}.team_rating
      where release_id = $1
    SQL

    exec_query_with_cache(query: sql, params: [[nil, release_id]], cache_key: "#{name}/#{release_id}/count").rows.first.first
  rescue NoMethodError
    0
  end

  def players_for_release(release_id:, top_place:, bottom_place:)
    sql = <<~SQL
      with ranked as (
        select rank() over (order by rating desc) as place, player_id, rating, rating_change
        from b.player_rating
        where release_id = $1
      )
      
      select r.*, p.first_name || ' ' || last_name as name
      from ranked r
      left join public.rating_player p on p.id = r.player_id
      where r.place >= $2 and r.place <= $3
      order by r.place;
    SQL

    exec_query_with_cache(query: sql,
      params: [[nil, release_id], [nil, top_place], [nil, bottom_place]],
      cache_key: "#{name}/#{release_id}/players/#{top_place}-#{bottom_place}")
  end

  def count_all_players_in_release(release_id:)
    sql = <<~SQL
      select count(*)
      from #{name}.player_rating
      where release_id = $1
    SQL

    exec_query_with_cache(query: sql, params: [[nil, release_id]], cache_key: "#{name}#{release_id}/players/count").rows.first.first
  rescue NoMethodError
    0
  end

  def team_tournaments(team_id:)
    sql = <<~SQL
      with ranked as (
        select rank() over (partition by release_id order by rating desc) as place,
               team_id, rating, rating_change, release_id
        from b.team_rating
      )
      
      select rel.id as release_id, rel.date as release_date, rating.place as release_place,
             rating.rating as release_rating, rating.rating_change as release_rating_change,
             t.id as id, t.title as name, t.end_datetime as date,
              r.position as place, tr.rating, tr.rating_change
      from b.release rel
      left join ranked rating on rating.team_id = $1 and rating.release_id = rel.id
      left join public.rating_tournament t on t.end_datetime < rel.date and t.end_datetime >= rel.date - interval '7 days'
      left join public.rating_result r on r.tournament_id = t.id
      left join b.tournament_result tr on tr.tournament_id = t.id and r.team_id = tr.team_id
      where r.team_id = $1
          and r.position != 0
          and t.maii_rating = true
      order by rel.date desc, t.end_datetime desc;
    SQL

    exec_query_with_cache(query: sql, params: [[nil, team_id]], cache_key: "#{name}/#{team_id}/tournaments").to_a
  end

  def old_tournaments(team_id:)
    sql = <<~SQL
      select t.id as id, t.title as name, t.end_datetime as date,
        r.position as place, ror.b as rating, ror.d as rating_change
      from public.rating_tournament t
      left join public.tournaments t_old_rating_flag on t.id = t_old_rating_flag.id
      left join public.rating_result r on r.team_id = $1 and r.tournament_id = t.id
      left join public.rating_oldteamrating ror on ror.result_id = r.id
      where r.team_id = $1
        and t_old_rating_flag.in_old_rating = true
      order by t.end_datetime desc
    SQL

    exec_query_with_cache(query: sql, params: [[nil, team_id]], cache_key: "#{name}/#{team_id}/old_tournaments").to_a
  end

  def team_details(team_id:)
    sql = <<~SQL
      select t.title as name, town.title as city
      from public.rating_team t
      left join public.rating_town town on t.town_id = town.id
      where t.id = $1
    SQL

    exec_query_with_cache(query: sql, params: [[nil, team_id]], cache_key: "#{name}/#{team_id}/details").rows.first
  end

  def team_players(team_id:)
    sql = <<~SQL
      select rr.tournament_id, p.id as player_id,
          p.first_name || ' ' || last_name as name,
          roster.flag
      from public.rating_result rr
      left join public.rating_oldrating roster on roster.result_id = rr.id
      left join public.rating_player p on roster.player_id = p.id
      where rr.team_id = $1
      order by rr.tournament_id, roster.flag, p.last_name
    SQL

    result = exec_query_with_cache(query: sql,
      params: [[nil, team_id]],
      cache_key: "#{name}/#{team_id}/players")

    result.each_with_object(Hash.new { |h, k| h[k] = [] }) do |row, hash|
      hash[row['tournament_id']] << row
    end
  end

  def tournament_results(tournament_id:)
    sql = <<~SQL
      select r.position as place, r.total as points, 
        r.team_title as team_name, r.team_id,
        tr.rating as rating, tr.rating_change as rating_change,
        tr.bp as forecast, tr.d1, tr.d2
      from public.rating_result r
      left join #{name}.tournament_result tr 
        on r.team_id = tr.team_id and tr.tournament_id = $1
      where r.tournament_id = $1
      order by position, r.team_id
    SQL

    exec_query_with_cache(query: sql, params: [[nil, tournament_id]], cache_key: "#{name}/#{tournament_id}/results").to_a
  end

  def tournament_players(tournament_id:)
    sql = <<~SQL
      select rr.team_id, p.id as player_id, 
        p.first_name || ' ' || last_name as name, 
        roster.flag
      from public.rating_result rr
      left join public.rating_oldrating roster on roster.result_id = rr.id
      left join public.rating_player p on roster.player_id = p.id
      where rr.tournament_id = $1
      order by rr.team_id, roster.flag, p.last_name
    SQL

    result = exec_query_with_cache(query: sql,
                                   params: [[nil, tournament_id]],
                                   cache_key: "#{name}/#{tournament_id}/players")

    result.each_with_object(Hash.new { |h, k| h[k] = [] }) do |row, hash|
      hash[row['team_id']] << row
    end
  end

  def tournament_details(tournament_id:)
    sql = <<~SQL
      select t.title as name, start_datetime, end_datetime
      from public.rating_tournament t
      where t.id = $1
    SQL

    exec_query_with_cache(query: sql, params: [[nil, tournament_id]], cache_key: "#{name}/#{tournament_id}/details").rows.first
  end

  def tournaments_list
    sql = <<~SQL
      with winners as (
          select tr.tournament_id, max(rating) as max_rating
          from #{name}.tournament_result tr
          group by tr.tournament_id
      )
      
      select t.id, t.title as name, type.title as type, t.end_datetime as date,
             w.max_rating as rating
      from public.rating_tournament t
      left join winners w on t.id = w.tournament_id
      left join public.rating_typeoft type on type.id = t.typeoft_id
      where t.maii_rating = true
        and t.end_datetime <= now() + interval '1 month'
      order by date desc
    SQL

    exec_query_with_cache(query: sql, params: nil, cache_key: "#{name}/tournaments_list").to_a
  end

  def player_details(player_id:)
    sql = <<~SQL
      select p.first_name || ' ' || last_name as name
      from public.rating_player p
      where p.id = $1
    SQL

    exec_query_with_cache(query: sql, params: [[nil, player_id]], cache_key: "#{name}/#{player_id}/details").rows.first.first
  end

  def player_tournaments(player_id:)
    sql = <<~SQL
      select t.id as id, t.title as name, t.end_datetime as date,
          rr.team_title as team_name, rr.position as place, rr.team_id, ro.flag, 
          case 
            when t.maii_rating = true then rating.rating
            when t_old_rating_flag.in_old_rating = true then ror.b
            else null
          end as rating,
          case 
            when t.maii_rating = true then rating.rating_change
            when t_old_rating_flag.in_old_rating = true then ror.d
            else null
          end as rating_change
      from public.rating_tournament t
      left join public.tournaments t_old_rating_flag on t.id = t_old_rating_flag.id
      left join public.rating_result rr on rr.tournament_id = t.id
      left join public.rating_oldrating ro on ro.result_id = rr.id
      left join public.rating_oldteamrating ror on ror.result_id = rr.id
      left join #{name}.tournament_result rating on rating.tournament_id = t.id and rating.team_id = rr.team_id
      where ro.player_id = $1
          and rr.position != 0
          and (t_old_rating_flag.in_old_rating = true or t.maii_rating = true)
      order by t.end_datetime desc
    SQL

    exec_query_with_cache(query: sql, params: [[nil, player_id]], cache_key: "#{name}/#{player_id}/tournaments").to_a
  end
end
