class TournamentsController < ApplicationController
  include InModel

  def show
    @tournament_id = params[:tournament_id].to_i

    @name, @start, @end = current_model.tournament_details(tournament_id: @tournament_id)
    @tournament_results = current_model.tournament_results(tournament_id: @tournament_id)

    all_players = current_model.tournament_players(tournament_id: @tournament_id)
    @tournament_results.each { |tr| tr['players'] = all_players[tr['team_id']]}
  end

  def index
    @tournaments = current_model.tournaments_list
  end
end
