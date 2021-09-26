class ReleaseTournamentPresenter
  attr_reader :release_id, :release_date, :release_place,
              :release_rating, :release_rating_change,
              :tournament_id, :name, :date,
              :team_name, :team_id, :place, :rating, :rating_change,
              :players

  attr_accessor :rows

  def initialize(release:, tournament: nil, players: nil, rows: 1)
    @release_id = release["id"]
    @release_date = I18n.l(release["date"].to_date, format: :short)
    @release_place = release["place"]
    @release_rating = release["rating"]
    @release_rating_change = release["rating_change"]

    if tournament.present?
      @tournament_id = tournament["id"]
      @name = tournament["name"]
      @date = I18n.l(tournament["date"].to_date, format: :short)
      @team_id = tournament["team_id"]
      @team_name = tournament["team_name"]
      @place = tournament["place"]
      @rating = tournament["rating"]
      @rating_change = tournament["rating_change"]
      @players = players
    end

    @rows = rows
  end
end