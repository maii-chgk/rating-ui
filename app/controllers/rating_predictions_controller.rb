class RatingPredictionsController < ApplicationController
  include InModel
  def show
    id = params[:tournament_id].to_i
    details = current_model.tournament_details(tournament_id: id)
    return render_404 if details.name.nil?

    results = current_model.tournament_results(tournament_id: id)

    all_players = current_model.tournament_players(tournament_id: id)
    results.each do |result|
      result.players = all_players[result["team_id"]]
      ratings = calculate_ratings(result)
      result.rt = ratings.rt
      result.rg = ratings.rg
      result.r = ratings.r
      result.rb = ratings.rb
    end
    results.sort_by! { |result| -result.rg }
    results.each_with_index { |result, i| result.place = i + 1 }

    @tournament = TournamentPresenter.new(id:, details:, results:)
  end

  def calculate_ratings(team)
    RCalculator.calculate(model: current_model, team_id: team.team_id, players: team.players.pluck("player_id"), date:)
  end

  def date
    Date.strptime(params[:date].to_s, "%Y-%m-%d")
  rescue ArgumentError
    Time.zone.today
  end
end
