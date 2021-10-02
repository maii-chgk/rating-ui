class TournamentPresenter
  attr_reader :id, :results

  # @param [integer] id
  # @param [TournamentPageDetails] details
  # @param [Array<TournamentResults>] results
  def initialize(id:, details:, results:)
    @id = id
    @details = details
    @results = results
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
end