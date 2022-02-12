module PlayerQueries
  include Cacheable

  PlayerTournament = Struct.new(:release_id, :id, :name, :date,
                                :team_name, :team_id, :place, :flag,
                                :rating, :rating_change, :in_rating,
                                keyword_init: true)

  PlayerOldTournament = Struct.new(:id, :name, :date,
                                   :team_name, :team_id, :place, :flag,
                                   :rating, :rating_change,
                                   keyword_init: true)

  PlayerRelease = Struct.new(:id, :date, :place, :rating, :rating_change, keyword_init: true)

  def player_name(player_id:)
    sql = <<~SQL
      select p.first_name || '&nbsp;' || last_name as name
      from public.players p
      where p.id = $1
    SQL

    exec_query_for_single_value(query: sql, params: [player_id])
  end

  def player_tournaments(player_id:)
    sql = <<~SQL
      select rel.id as release_id, t.id as id, t.title as name, t.end_datetime as date,
          rr.team_title as team_name, rr.position as place, rr.team_id, tr.flag, 
          rating.rating, rating.rating_change, rating.is_in_maii_rating as in_rating
      from #{name}.release rel
      left join public.tournament_details t 
          on t.end_datetime < rel.date + interval '24 hours' and t.end_datetime >= rel.date - interval '6 days'
      left join public.tournament_results rr 
          on rr.tournament_id = t.id
      left join public.tournament_rosters tr 
          on tr.tournament_id = t.id and tr.team_id = rr.team_id
      left join #{name}.tournament_result rating 
          on rating.tournament_id = t.id and rating.team_id = rr.team_id
      where tr.player_id = $1
          and rr.position != 0
          and t.maii_rating = true
      order by t.end_datetime desc
    SQL

    exec_query(query: sql, params: [player_id], result_class: PlayerTournament)
  end

  def player_old_tournaments(player_id:)
    sql = <<~SQL
      select t.id as id, t.title as name, t.end_datetime as date,
          r.team_title as team_name, r.position as place, r.team_id, tr.flag, 
          r.old_rating as rating, r.old_rating_delta as rating_change
      from public.tournament_details t
      left join public.tournament_results r on r.tournament_id = t.id
      left join public.tournament_rosters tr on tr.tournament_id = t.id and tr.team_id = r.team_id
      where tr.player_id = $1
        and t.in_old_rating = true
        and t.end_datetime < '2021-09-01'
      order by t.end_datetime desc
    SQL

    exec_query(query: sql, params: [player_id], result_class: PlayerOldTournament)
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

    exec_query(query: sql, params: [player_id], result_class: PlayerRelease)
  end
end
