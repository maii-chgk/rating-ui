module TournamentQueries
  include Cacheable

  TournamentResults = Struct.new(:team_id, :team_name, :place, :points,
                                 :rating, :rating_change, :in_rating,
                                 :forecast, :forecast_place,
                                 :d1, :d2, :players,
                                 keyword_init: true)

  TournamentPageDetails = Struct.new(:name, :start, :end)

  TournamentListDetails = Struct.new(:id, :name, :type, :date, :rating, keyword_init: true)

  def tournament_results(tournament_id:)
    sql = <<~SQL
      select r.position as place, r.total as points, 
          r.team_title as team_name, r.team_id,
          tr.rating as rating, tr.rating_change as rating_change,
          tr.is_in_maii_rating as in_rating,
          tr.bp as forecast, tr.d1, tr.d2
      from public.rating_result r
      left join #{name}.tournament_result tr 
          on r.team_id = tr.team_id and tr.tournament_id = $1
      where r.tournament_id = $1
      order by position, r.team_id
    SQL

    exec_query(query: sql,
               params: [tournament_id],
               cache_key: "#{name}/#{tournament_id}/results",
               result_class: TournamentResults)
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

    result = exec_query_for_hash_array(query: sql,
                                       params: [tournament_id],
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

    row = exec_query_for_single_row(query: sql,
                                    params: [tournament_id],
                                    cache_key: "#{name}/#{tournament_id}/details")
    TournamentPageDetails.new(*row)
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

    exec_query(query: sql, cache_key: "#{name}/tournaments_list", result_class: TournamentListDetails)
  end
end
