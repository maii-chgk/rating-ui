# frozen_string_literal: true

class TournamentPresenter
  attr_reader :id, :results

  Results = Struct.new(:team_id, :team_name, :team_city, :place, :points,
    :rating, :rating_change, :in_rating, :predicted_rating, :predicted_place,
    :d1, :d2, :players, :r, :rt, :rg, :rb,
    :truedl)

  # @param [integer] id
  # @param [Tournament] tournament
  # @param [Array<TournamentResults>] results
  # @param [Hash] truedls
  def initialize(id:, tournament:, results:, truedls: {})
    @id = id
    @tournament = tournament
    @results = results.map do |result|
      Results.new(**result.to_h, truedl: truedls[result.team_id])
    end
  end

  def name
    @tournament.title
  end

  def start
    I18n.l(@tournament.start_datetime.to_date)
  end

  def end
    I18n.l(@tournament.end_datetime.to_date)
  end

  def in_rating?
    @tournament.maii_rating
  end
end
