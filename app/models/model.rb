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

    exec_query_with_cache(query: sql, cache_key: "#{name}/all_releases").to_a
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

  def count_all_teams_in_release(release_id:)
    sql = <<~SQL
      select count(*)
      from #{name}.releases
      where release_details_id = $1
    SQL

    exec_query_with_cache(query: sql, params: [[nil, release_id]], cache_key: "#{name}/#{release_id}/count").rows.first.first
  rescue NoMethodError
    0
  end

  def team_tournaments(team_id:)
    sql = <<~SQL
      select tr.tournament_id, t.title as name, t.end_datetime as date,
        r.position as place, tr.rating_change as rating
      from public.rating_tournament t
      left join public.rating_result r on r.team_id = $1 and r.tournament_id = t.id
      left join #{name}.tournament_results tr on tr.tournament_id = t.id
      where r.team_id = $1
      order by t.end_datetime desc
    SQL

    exec_query_with_cache(query: sql, params: [[nil, team_id]], cache_key: "#{name}/#{team_id}/tournaments").to_a
  end

  def team_details(team_id:)
    sql = <<~SQL
      select t.title as name, town.title as city
      from public.rating_team t
      left join public.rating_town town on t.town_id = town.id
      where t.id = $1
    SQL

    exec_query_with_cache(query: sql, params: [[nil, team_id]], cache_key: "#{name}/#{team_id}/details").rows.first
  end
end
