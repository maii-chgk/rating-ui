class TeamsController < ApplicationController
  include InModel

  def show
    @name, @city = current_model.team_details(team_id: clean_params[:team_id])
    @tournaments = current_model.team_tournaments(team_id: clean_params[:team_id])
  end

  def clean_params
    params.permit(:team_id)
  end
end
