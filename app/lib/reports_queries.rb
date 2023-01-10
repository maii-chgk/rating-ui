module ReportsQueries
  include Cacheable

  MonthCount = Struct.new(:MonthCount, :month, :count, keyword_init: true)

  def active_rating_players
    sql = <<~SQL
      with rating_tournaments as (
          select date_trunc('month', end_datetime) as month, *
          from tournaments
          where maii_rating = true
            and end_datetime between '2021-09-01' and date_trunc('month', current_date)
      )
      
      select to_char(rt.month, 'mm.YYYY') as month, count(distinct player_id) as count
      from rating_tournaments rt
      left join tournament_rosters tr on rt.id = tr.tournament_id
      group by rt.month
      order by rt.month;
    SQL

    exec_query(query: sql,
               result_class: MonthCount)
  end
end
