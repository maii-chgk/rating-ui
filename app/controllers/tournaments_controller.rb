# frozen_string_literal: true

class TournamentsController < ApplicationController
  include InModel

  def index
    @tournaments = current_model.tournaments_list
    @true_dls = TrueDl.where(model: current_model, tournament_id: @tournaments.map(&:id))
      .group(:tournament_id)
      .average(:true_dl)
      .to_h
  end

  def show
    id = params[:tournament_id].to_i
    details = current_model.tournament_details(tournament_id: id)
    return render_404 if details.name.nil?

    results = current_model.tournament_results(tournament_id: id)

    all_players = current_model.tournament_players(tournament_id: id)
    results.each { |tr| tr.players = all_players[tr["team_id"]] }

    true_dls_by_team = TrueDLCalculator.tournament_dl_by_team(tournament_id: id, model: current_model)
    @true_dl = true_dls_by_team.values.sum / true_dls_by_team.size.to_f unless true_dls_by_team.empty?

    @tournament = TournamentPresenter.new(id:, details:, results:, truedls: true_dls_by_team)
  end
end
