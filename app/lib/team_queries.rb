module TeamQueries
  include Cacheable

  TeamTournament = Struct.new(:release_id, :id, :name, :date, :place,
                              :rating, :rating_change, :in_rating,
                              keyword_init: true)

  TeamOldTournament = Struct.new(:id, :name, :date, :place, :rating, :rating_change, :players,
                                 keyword_init: true)

  TeamRelease = Struct.new(:id, :date, :place, :rating, :rating_change, keyword_init: true)

  def team_tournaments(team_id:)
    sql = <<~SQL
      select rel.id as release_id,
             t.id as id, t.title as name, t.end_datetime as date,
             r.position as place, 
             tr.rating, tr.rating_change, tr.is_in_maii_rating as in_rating  
      from #{name}.release rel
      left join public.rating_tournament t 
          on t.end_datetime < rel.date + interval '24 hours' and t.end_datetime >= rel.date - interval '6 days'
      left join public.rating_result r 
          on r.tournament_id = t.id
      left join #{name}.tournament_result tr 
          on tr.tournament_id = t.id and r.team_id = tr.team_id
      where r.team_id = $1
          and r.position != 0
          and t.maii_rating = true
      order by t.end_datetime desc;
    SQL

    exec_query(query: sql,
               params: [team_id],
               cache_key: "#{name}/#{team_id}/tournaments",
               result_class: TeamTournament)
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

    exec_query(query: sql,
               params: [team_id],
               cache_key: "#{name}/#{team_id}/old_tournaments",
               result_class: TeamOldTournament)
  end

  def team_details(team_id:)
    sql = <<~SQL
      select t.title as name, town.title as city
      from public.rating_team t
      left join public.rating_town town on t.town_id = town.id
      where t.id = $1
    SQL

    exec_query_for_single_row(query: sql, params: [team_id], cache_key: "#{name}/#{team_id}/details")
  end

  def team_players(team_id:)
    sql = <<~SQL
      select rr.tournament_id, p.id as player_id,
          p.first_name || '&nbsp;' || last_name as name,
          roster.flag
      from public.rating_result rr
      left join public.rating_oldrating roster on roster.result_id = rr.id
      left join public.rating_player p on roster.player_id = p.id
      where rr.team_id = $1
      order by rr.tournament_id, roster.flag, p.last_name
    SQL

    result = exec_query_for_hash_array(query: sql,
                                       params: [team_id],
                                       cache_key: "#{name}/#{team_id}/players")

    result.each_with_object(Hash.new { |h, k| h[k] = [] }) do |row, hash|
      hash[row['tournament_id']] << row
    end
  end

  def team_releases(team_id:)
    sql = <<~SQL
      with ranked as (
        select rank() over (partition by release_id order by rating desc) as place,
               team_id, rating, rating_change, release_id
        from #{name}.team_rating
      )
      
      select rel.id, rel.date, rating.place, rating.rating, rating.rating_change  
      from #{name}.release rel
      left join ranked rating on rating.team_id = $1 and rating.release_id = rel.id
      order by rel.date desc;
    SQL

    exec_query(query: sql,
               params: [team_id],
               cache_key: "#{name}/#{team_id}/releases",
               result_class: TeamRelease)
  end
end
