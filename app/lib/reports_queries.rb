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

  def old_rating_players
    sql = <<~SQL
      with rating_tournaments as (
          select date_trunc('month', end_datetime) as month, *
          from tournaments
          where in_old_rating = true
      ),

      months as (select generate_series('2005-01-01', date_trunc('month', current_date), '1 month') as month)

      select to_char(m.month, 'mm.YYYY') as month, count(distinct player_id) as count
      from months m
      left join rating_tournaments rt using(month)
      left join tournament_rosters tr on rt.id = tr.tournament_id
      group by m.month
      order by m.month;
    SQL

    exec_query(query: sql,
               result_class: MonthCount)
  end

  def all_players
    sql = <<~SQL
      with all_tournaments as (
            select date_trunc('month', end_datetime) as month, *
            from tournaments
            where type != 'Общий зачёт'
        ),

        months as (select generate_series('2005-01-01', date_trunc('month', current_date), '1 month') as month)

        select to_char(m.month, 'mm.YYYY') as month, count(distinct player_id) as count
        from months m
        left join all_tournaments at using(month)
        left join tournament_rosters tr on at.id = tr.tournament_id
        group by m.month
        order by m.month;
    SQL

    exec_query(query: sql,
               result_class: MonthCount)
  end
end
