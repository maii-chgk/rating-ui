class Team < ApplicationRecord
  belongs_to :town
  self.primary_key = "id"

  def self.team_details_by_id(team_id)
    Team.joins(:town)
      .select("teams.id as id, teams.title AS name, towns.title AS city")
      .find_by(id: team_id)
  end

  def self.players_in_all_tournaments(team_id)
    TournamentResult.where(team_id:)
      .joins("left join tournament_rosters using (tournament_id, team_id)")
      .joins("left join players on players.id = tournament_rosters.player_id")
      .order("tournament_rosters.flag, players.last_name")
      .select(:tournament_id, "players.id as player_id", players: [:first_name, :last_name], tournament_rosters: [:flag])
      .group_by(&:tournament_id)
  end
end
