class TeamsController < ApplicationController
  include InModel

  def show
    @team_id = params[:team_id].to_i
    @name, @city = current_model.team_details(team_id: @team_id)
    @tournaments = current_model.team_tournaments(team_id: @team_id)

    all_players = current_model.team_players(team_id: @team_id)
    @tournaments.each { |t| t['players'] = all_players[t['id']]}
  end
end
