module PlayerQueries
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
      select rel.id as release_id, t.id as id, t.title as name, t.end_datetime as date,
          rr.team_title as team_name, rr.position as place, rr.team_id, ro.flag, 
          rating.rating, rating.rating_change
      from #{name}.release rel
      left join public.rating_tournament t 
          on t.end_datetime < rel.date + interval '24 hours' and t.end_datetime >= rel.date - interval '6 days'
      left join public.tournaments t_old_rating_flag 
          on t.id = t_old_rating_flag.id
      left join public.rating_result rr 
          on rr.tournament_id = t.id
      left join public.rating_oldrating ro 
          on ro.result_id = rr.id
      left join #{name}.tournament_result rating 
          on rating.tournament_id = t.id and rating.team_id = rr.team_id
      where ro.player_id = $1
          and rr.position != 0
          and t.maii_rating = true
      order by t.end_datetime desc
    SQL

    exec_query_with_cache(query: sql, params: [[nil, player_id]], cache_key: "#{name}/#{player_id}/tournaments").to_a
  end

  def player_old_tournaments(player_id:)
    sql = <<~SQL
      select t.id as id, t.title as name, t.end_datetime as date,
          rr.team_title as team_name, rr.position as place, rr.team_id, ro.flag, 
          ror.b as rating, ror.d as rating_change
      from public.rating_tournament t
      left join public.tournaments t_old_rating_flag on t.id = t_old_rating_flag.id
      left join public.rating_result r on r.team_id = $1 and r.tournament_id = t.id
      left join public.rating_result rr on rr.tournament_id = t.id
      left join public.rating_oldrating ro on ro.result_id = rr.id
      left join public.rating_oldteamrating ror on ror.result_id = rr.id
      where ro.player_id = $1
        and t_old_rating_flag.in_old_rating = true
      order by t.end_datetime desc
    SQL

    exec_query_with_cache(query: sql, params: [[nil, player_id]], cache_key: "#{name}/#{player_id}/old_tournaments").to_a
  end

  def player_releases(player_id:)
    sql = <<~SQL
      with ranked as (
        select rank() over (partition by release_id order by rating desc) as place,
               player_id, rating, rating_change, release_id
        from #{name}.player_rating
      )
      
      select rel.id, rel.date, rating.place, rating.rating, rating.rating_change  
      from #{name}.release rel
      left join ranked rating on rating.player_id = $1 and rating.release_id = rel.id
      order by rel.date desc;
    SQL

    exec_query_with_cache(query: sql, params: [[nil, player_id]], cache_key: "#{name}/#{player_id}/player_releases").to_a
  end
end
