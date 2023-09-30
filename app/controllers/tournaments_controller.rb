# frozen_string_literal: true

class TournamentsController < ApplicationController
  include InModel

  def index
    @tournaments = current_model.tournaments_list
  end

  def show
    id = params[:tournament_id].to_i
    details = current_model.tournament_details(tournament_id: id)
    return render_404 if details.name.nil?

    results = current_model.tournament_results(tournament_id: id)

    all_players = current_model.tournament_players(tournament_id: id)
    results.each { |tr| tr.players = all_players[tr['team_id']] }

    @tournament = TournamentPresenter.new(id:, details:, results:)
    @true_dl = TrueDl.find_by(model: current_model, tournament_id: id).true_dl
  end
end
