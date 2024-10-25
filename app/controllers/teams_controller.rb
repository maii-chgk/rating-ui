# frozen_string_literal: true

class TeamsController < ApplicationController
  include InModel

  def show
    team_id = params[:team_id].to_i
    @team = Team.team_details_by_id(team_id)
    return render_404 if @team.nil?

    releases = current_model.team_releases(team_id:)
    tournaments = current_model.team_tournaments(team_id:)
    all_players = current_model.team_players(team_id:)

    @rows = ReleaseTournamentBuilder.build(releases, tournaments, all_players)
    @current_season = Season.current_season

    @old_tournaments = current_model.old_tournaments(team_id:)
    @old_tournaments.each { |t| t.players = all_players[t["id"]] }

    @base_roster = current_model.team_current_base_roster(team_id:)
  end
end
