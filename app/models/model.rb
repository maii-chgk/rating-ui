class Model < ApplicationRecord
  include Cacheable

  def teams_for_release(release_id:, top_place:, bottom_place:)
    sql = <<~SQL
      with ranked as (
          select rank() over (order by rating desc) as place, team_id, rating, rating_change
          from random.releases
          where release_details_id = $1
      )
      
      select r.*, t.title as name, town.title as city
      from ranked r
      left join public.rating_team t on r.team_id = t.id
      left join public.rating_town town on town.id = t.town_id
      where r.place >= $2 and r.place <= $3
      order by r.place;
    SQL

    exec_query_with_cache(query: sql,
      params: [[nil, release_id], [nil, top_place], [nil, bottom_place]],
      cache_key: "#{name}/#{release_id}/#{top_place}-#{bottom_place}")
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
  rescue NoMethodError
    -1
  end
end
