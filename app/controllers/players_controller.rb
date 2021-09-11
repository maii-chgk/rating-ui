class PlayersController < ApplicationController
  include InModel

  def show
    @player_id = params[:player_id].to_i
    @name = current_model.player_details(player_id: @player_id)
    @tournaments = current_model.player_tournaments(player_id: @player_id)
  end
end
