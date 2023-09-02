# frozen_string_literal: true

module TeamQueries
  include Cacheable

  TeamTournament = Struct.new(:release_id, :id, :name, :date, :place,
                              :rating, :rating_change, :in_rating,
                              keyword_init: true)

  TeamOldTournament = Struct.new(:id, :name, :date, :place, :rating, :rating_change, :players,
                                 keyword_init: true)

  TeamRelease = Struct.new(:id, :date, :place, :rating, :rating_change, keyword_init: true)

  def team_tournaments(team_id:)
    sql = <<~SQL
      select rel.id as release_id,
             t.id as id, t.title as name, t.end_datetime as date,
             r.position as place,
             tr.rating, tr.rating_change, tr.is_in_maii_rating as in_rating
      from #{name}.release rel
      left join public.tournaments t
          on t.end_datetime < rel.date + interval '24 hours' and t.end_datetime >= rel.date - interval '6 days'
      left join public.tournament_results r
          on r.tournament_id = t.id
      left join #{name}.tournament_result tr
          on tr.tournament_id = t.id and r.team_id = tr.team_id
      where r.team_id = $1
          and r.position != 0
          and t.maii_rating = true
      order by t.end_datetime desc;
    SQL

    exec_query(query: sql,
               params: [team_id],
               result_class: TeamTournament)
  end

  def old_tournaments(team_id:)
    sql = <<~SQL
      select t.id as id, t.title as name, t.end_datetime as date,
        r.position as place, r.old_rating as rating, r.old_rating_delta as rating_change
      from public.tournaments t
      left join public.tournament_results r on r.team_id = $1 and r.tournament_id = t.id
      where r.team_id = $1
        and t.in_old_rating = true
        and t.end_datetime < '2021-09-01'
      order by t.end_datetime desc
    SQL

    exec_query(query: sql, params: [team_id], result_class: TeamOldTournament)
  end

  def team_details(team_id:)
    sql = <<~SQL
      select t.title as name, town.title as city
      from public.teams t
      left join public.towns town on t.town_id = town.id
      where t.id = $1
    SQL

    exec_query_for_single_row(query: sql, params: [team_id])
  end

  def team_players(team_id:)
    sql = <<~SQL
      select rr.tournament_id, p.id as player_id,
          p.first_name || '&nbsp;' || last_name as name,
          tr.flag
      from public.tournament_results rr
      left join public.tournament_rosters tr using (tournament_id, team_id)
      left join public.players p on tr.player_id = p.id
      where rr.team_id = $1
      order by tr.flag, p.last_name
    SQL

    exec_query_for_hash(query: sql, params: [team_id], group_by: 'tournament_id')
  end

  def team_releases(team_id:)
    sql = <<~SQL
      select rel.id, rel.date, ranking.place, ranking.rating, ranking.rating_change
      from #{name}.release rel
      left join #{name}.team_ranking ranking on ranking.team_id = $1 and ranking.release_id = rel.id
      order by rel.date desc;
    SQL

    exec_query(query: sql, params: [team_id], result_class: TeamRelease)
  end

  def team_current_base_roster(team_id:)
    sql = <<~SQL
       select br.player_id, p.first_name || '&nbsp;' || p.last_name as name
       from public.base_rosters br
       left join public.players p on p.id = br.player_id
       where br.season_id = #{CurrentSeason.id}
         and current_date >= br.start_date
         and (br.end_date < current_date or br.end_date is null)
         and br.team_id = $1
      order by p.last_name
    SQL

    exec_query_for_hash_array(query: sql, params: [team_id])
  end
end
