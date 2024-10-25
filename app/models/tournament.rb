class Tournament < ApplicationRecord
  self.primary_key = "id"
  self.inheritance_column = nil

  has_many :tournament_results, dependent: :destroy
  has_many :tournament_rosters, dependent: :destroy

  def self.pre_maii_tournaments_for_team(team_id)
    Tournament.joins(:tournament_results)
      .where(tournament_results: {team_id:})
      .where(in_old_rating: true)
      .where(end_datetime: ...Season::FIRST_MAII_SEASON_START)
      .order(end_datetime: :desc)
      .select(:id, "title as name", "end_datetime as date",
        "tournament_results.position as place",
        "tournament_results.old_rating as rating",
        "tournament_results.old_rating_delta as rating_change")
  end
end
