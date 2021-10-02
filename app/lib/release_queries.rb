module ReleaseQueries
  include Cacheable

  ReleaseTeam = Struct.new(:team_id, :name, :city,
                           :place, :rating, :rating_change,
                           keyword_init: true)

  ReleasePlayer = Struct.new(:player_id, :name, :city,
                             :place, :rating, :rating_change,
                             keyword_init: true)

  def teams_for_release(release_id:, top_place:, bottom_place:)
    sql = <<~SQL
      with ranked as (
          select rank() over (order by rating desc) as place, team_id, rating, rating_change
          from #{name}.team_rating
          where release_id = $1
      )
      
      select r.*, t.title as name, town.title as city
      from ranked r
      left join public.rating_team t on r.team_id = t.id
      left join public.rating_town town on town.id = t.town_id
      where r.place >= $2 and r.place <= $3
      order by r.place;
    SQL

    exec_query(query: sql,
               params: [release_id, top_place, bottom_place],
               cache_key: "#{name}/#{release_id}/#{top_place}-#{bottom_place}",
               result_class: ReleaseTeam)
  end

  def all_releases
    sql = <<~SQL
      select date, id
      from #{name}.release
      order by date desc
    SQL

    exec_query_for_hash_array(query: sql, cache_key: "#{name}/all_releases")
  end

  def latest_release_id
    sql = <<~SQL
      select id
      from #{name}.release
      where date = (select max(date) as max_date from #{name}.release)
    SQL

    exec_query_for_single_value(query: sql, cache_key: "#{name}/latest_release")
  end

  def count_all_teams_in_release(release_id:)
    sql = <<~SQL
      select count(*)
      from #{name}.team_rating
      where release_id = $1
    SQL

    exec_query_for_single_value(query: sql,
                                params: [release_id],
                                cache_key: "#{name}/#{release_id}/count",
                                default_value: 0)
  end

  def players_for_release(release_id:, top_place:, bottom_place:)
    sql = <<~SQL
      with ranked as (
        select rank() over (order by rating desc) as place, player_id, rating, rating_change
        from #{name}.player_rating
        where release_id = $1
      )
      
      select r.*, p.first_name || '&nbsp;' || last_name as name
      from ranked r
      left join public.rating_player p on p.id = r.player_id
      where r.place >= $2 and r.place <= $3
      order by r.place;
    SQL

    exec_query(query: sql,
               params: [release_id, top_place, bottom_place],
               cache_key: "#{name}/#{release_id}/players/#{top_place}-#{bottom_place}",
               result_class: ReleasePlayer)
  end

  def count_all_players_in_release(release_id:)
    sql = <<~SQL
      select count(*)
      from #{name}.player_rating
      where release_id = $1
    SQL

    exec_query_for_single_value(query: sql,
                                params: [release_id],
                                cache_key: "#{name}#{release_id}/players/count",
                                default_value: 0)
  end
end
