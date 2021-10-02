class ReleaseTournamentPresenter
  attr_reader :players
  attr_accessor :rows

  def initialize(release:, tournament: nil, players: nil, rows: 1)
    @release = release
    @tournament = tournament
    @players = players if tournament.present?
    @rows = rows
  end

  def release_id
    @release["id"]
  end

  def release_date
    I18n.l(@release["date"].to_date, format: :short)
  end

  def release_place
    @release["place"]
  end

  def release_rating
    @release["rating"]
  end

  def release_rating_change
    @release["rating_change"]
  end

  def tournament_id
    @tournament["id"] if @tournament.present?
  end

  def name
    @tournament["name"] if @tournament.present?
  end

  def date
    I18n.l(@tournament["date"].to_date, format: :short) if @tournament.present?
  end

  def team_id
    @tournament["team_id"] if @tournament.present?
  end

  def team_name
    @tournament["team_name"] if @tournament.present?
  end

  def place
    @tournament["place"] if @tournament.present?
  end

  def rating
    @tournament["rating"] if @tournament.present?
  end

  def rating_change
    return nil if @tournament.nil?
    if @tournament["in_rating"] == true
      @tournament["rating_change"]
    else
      "[#{@tournament['rating_change']}]"
    end
  end
end