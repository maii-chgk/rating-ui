# frozen_string_literal: true

class TournamentPresenter
  attr_reader :id, :results

  Results = Struct.new(:team_id, :team_name, :team_city, :place, :points,
    :rating, :rating_change, :in_rating, :predicted_rating, :predicted_place,
    :d1, :d2, :players, :r, :rt, :rg, :rb,
    :truedl)

  # @param [integer] id
  # @param [TournamentPageDetails] details
  # @param [Array<TournamentResults>] results
  # @param [Hash] truedls
  def initialize(id:, details:, results:, truedls: {})
    @id = id
    @details = details
    @results = results.map do |result|
      Results.new(**result.to_h, truedl: truedls[result.team_id])
    end
  end

  def name
    @details.name
  end

  def start
    I18n.l(@details.start.to_date)
  end

  def end
    I18n.l(@details.end.to_date)
  end

  def in_rating?
    @details.maii_rating
  end
end
