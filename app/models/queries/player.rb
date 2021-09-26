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