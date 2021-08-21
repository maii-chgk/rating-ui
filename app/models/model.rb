class Model < ApplicationRecord
  def all_teams_for_release(release_id)
    sql = <<~SQL
      select team_id, t.title as name, r.rating, r.rating_change
      from #{name}.releases r
      left join public.rating_team t on r.team_id = t.r_id 
      where id = $1
      order by r.rating desc
    SQL
    ActiveRecord::Base.connection.exec_query(sql, binds: [[nil, release_id]])
  end

  def all_teams_for_latest_release
    sql = <<~SQL
      select team_id, t.title as name, r.rating, r.rating_change
      from #{name}.releases r
      left join public.rating_team t on r.team_id = t.r_id 
      where r.id = (select max(id) from #{name}.releases)
      order by r.rating desc
    SQL
    ActiveRecord::Base.connection.exec_query(sql)
  end
end
