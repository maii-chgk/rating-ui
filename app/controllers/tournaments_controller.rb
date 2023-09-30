# frozen_string_literal: true

require 'true_dl'

class TournamentsController < ApplicationController
  include InModel

  def index
    @tournaments = current_model.tournaments_list
  end

  def show
    id = params[:tournament_id].to_i
    @details = current_model.tournament_details(tournament_id: id)
    return render_404 if @details.name.nil?

    @results = current_model.tournament_results(tournament_id: id)

    all_players = current_model.tournament_players(tournament_id: id)
    @results.each { |tr| tr.players = all_players[tr['team_id']] }

    @tournament = TournamentPresenter.new(id:, details: @details, results: @results)

    @true_dl = calculate_true_dl
  end

  def calculate_true_dl
    rankings = current_model.teams_ranking(list_of_team_ids: @results.map(&:team_id), date: @details.start)

    teams = @results.map do |result|
      next if rankings[result.team_id].blank?

      { points: result.points, ranking: rankings[result.team_id].first['place'] }
    end.compact

    @true_dl = TrueDL.true_dl_for_tournament(teams:, number_of_questions: @details.questions_count)
  end
end
