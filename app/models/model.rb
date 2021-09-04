class Model < ApplicationRecord
  include Cacheable

  def teams_for_release(release_id)
    sql = <<~SQL
      select team_id, t.title as name, r.rating, r.rating_change
      from #{name}.releases r
      left join public.rating_team t on r.team_id = t.id 
      where release_details_id = $1
      order by r.rating desc
    SQL

    exec_query_with_cache(query: sql, params: [nil, release_id], cache_key: "#{name}/#{release_id}")
  end

  def all_releases
    sql = <<~SQL
      select date, id
      from #{name}.release_details
      order by date desc
    SQL

    releases = exec_query_with_cache(query: sql, cache_key: "#{name}/all_releases").to_a
    releases.each { |release| release['date'] = I18n.l(release['date'].to_date) }
    releases
  end

  def latest_release_id
    sql = <<~SQL
      select id
      from #{name}.release_details
      where date = (select max(date) as max_date from #{name}.release_details)
    SQL

    exec_query_with_cache(query: sql, cache_key: "#{name}/latest_release_details").rows.first.first
  end
end
