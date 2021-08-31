class Model < ApplicationRecord
  include Cacheable

  def all_teams_for_release(release_id)
    sql = <<~SQL
      select team_id, t.title as name, r.rating, r.rating_change
      from #{name}.releases r
      left join public.rating_team t on r.team_id = t.id 
      where release_details_id = $1
      order by r.rating desc
    SQL

    exec_query_with_cache(query: sql, params: [nil, release_id], cache_key: release_id)
  end

  def all_teams_for_latest_release
    sql = <<~SQL
      select team_id, t.title as name, r.rating, r.rating_change
      from #{name}.releases r
      left join public.rating_team t on r.team_id = t.id
      join #{name}.release_details rd on r.release_details_id = rd.id
      join (select max(date) as max_date from #{name}.release_details) rd_max on rd.date = rd_max.max_date
      order by r.rating desc
    SQL

    exec_query_with_cache(query: sql, cache_key: "#{id}/latest")
  end
end
