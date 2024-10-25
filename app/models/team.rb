class Team < ApplicationRecord
  belongs_to :town
  self.primary_key = "id"

  def self.team_details_by_id(team_id)
    Team.joins(:town)
      .select("teams.id as id, teams.title AS name, towns.title AS city")
      .find_by(id: team_id)
  end
end
