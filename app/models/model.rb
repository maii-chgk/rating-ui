class Model < ApplicationRecord
  def all_teams_for_release(release_id)
    sql = <<~SQL
      select team_id, t.title as name, r.rating, r.rating_change
      from #{name}.releases r
      left join public.rating_team t on r.team_id = t.r_id 
      where release_details_id = $1
      order by r.rating desc
    SQL
    ActiveRecord::Base.connection.exec_query(sql, "", [[nil, release_id]])
  end

  def all_teams_for_latest_release
    sql = <<~SQL
      select team_id, t.title as name, r.rating, r.rating_change
      from #{name}.releases r
      left join public.rating_team t on r.team_id = t.r_id
      join #{name}.release_details rd on r.release_details_id = rd.id
      join (select max(date) as max_date from #{name}.release_details) rd_max on rd.date = rd_max.max_date
      order by r.rating desc
    SQL
    ActiveRecord::Base.connection.exec_query(sql)
  end
end
