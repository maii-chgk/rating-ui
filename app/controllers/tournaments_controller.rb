class TournamentsController < ApplicationController
  include InModel

  def show
    id = params[:tournament_id].to_i
    details = current_model.tournaments(tournament_id: id)
    return render_404 if details.name.nil?

    results = current_model.tournament_results(tournament_id: id)

    all_players = current_model.tournament_players(tournament_id: id)
    results.each { |tr| tr.players = all_players[tr['team_id']]}

    @tournament = TournamentPresenter.new(id: id, details: details, results: results)
  end

  def index
    @tournaments = current_model.tournaments_list
  end
end
