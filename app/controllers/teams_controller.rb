class TeamsController < ApplicationController
  include InModel

  def show
    @team_id = params[:team_id].to_i
    @name, @city = current_model.team_details(team_id: @team_id)

    @old_tournaments = current_model.old_tournaments(team_id: @team_id)
    @tournaments = current_model.team_tournaments(team_id: @team_id)
    group_tournaments_by_release!

    all_players = current_model.team_players(team_id: @team_id)
    @tournaments.each { |t| t['players'] = all_players[t['id']]}
    @old_tournaments.each { |t| t['players'] = all_players[t['id']]}
  end

  private

  def group_tournaments_by_release!
    counts = @tournaments.each_with_object(Hash.new(0)) do |tournament, hash|
      hash[tournament['release_id']] += 1
    end
    @tournaments.each do |tournament|
      tournaments_in_release = counts[tournament["release_id"]]
      next if tournaments_in_release.nil?
      tournament["tournaments_in_release"] = tournaments_in_release
      counts[tournament["release_id"]] = nil
    end
  end
end
