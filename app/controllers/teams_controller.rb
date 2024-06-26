# frozen_string_literal: true

class TeamsController < ApplicationController
  include InModel

  def show
    @team_id = params[:team_id].to_i
    @name, @city = current_model.team_details(team_id: @team_id)
    return render_404 if @name.nil?

    releases = current_model.team_releases(team_id: @team_id)
    tournaments = current_model.team_tournaments(team_id: @team_id)
    all_players = current_model.team_players(team_id: @team_id)

    @rows = ReleaseTournamentBuilder.build(releases, tournaments, all_players)

    @old_tournaments = current_model.old_tournaments(team_id: @team_id)
    @old_tournaments.each { |t| t.players = all_players[t["id"]] }

    @base_roster = current_model.team_current_base_roster(team_id: @team_id)
  end
end
