# frozen_string_literal: true

class PlayersController < ApplicationController
  include InModel

  def show
    @player_id = params[:player_id].to_i
    @name = current_model.player_name(player_id: @player_id)
    return render_404 if @name.nil?

    releases = current_model.player_releases(player_id: @player_id)
    tournaments = current_model.player_tournaments(player_id: @player_id)
    @rows = ReleaseTournamentBuilder.build(releases, tournaments, {})

    @old_tournaments = current_model.player_old_tournaments(player_id: @player_id)
  end
end
