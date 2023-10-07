# frozen_string_literal: true

require 'true_dl'

module TrueDL
  TrueDLInput = Data.define(:teams, :questions_count)

  def self.calculate_for_tournament(tournament_id:, model_name:)
    TournamentCalculator.new(tournament_id, model_name).run
  end

  def self.calculate_for_all_maii_tournaments(model_name:)
    model = Model.find_by(name: model_name)
    unless model
      Rails.logger.error "no model with the name #{model_name}"
      return
    end

    tournaments = model.all_tournaments_after_date(date: '2021-09-01')
    Rails.logger.info "calculating truedl for #{tournaments.size} tournaments"

    tournaments.each_with_index do |tournament, index|
      calculate_for_tournament(tournament_id: tournament['id'], model_name:)
      Rails.logger.info "Progress: #{index + 1}/#{tournaments.size}" if (index + 1) % 10 == 0
    end
  end

  class TournamentCalculator
    attr_reader :tournament_id, :model

    def initialize(tournament_id, model_name)
      @model = Model.find_by(name: model_name)
      @tournament_id = tournament_id
    end

    def run
      unless model
        Rails.logger.info "no model with the name #{model_name}"
        return
      end

      true_dl_input = fetch_data_for_true_dl
      return unless true_dl_input

      dl_value = TrueDL.true_dl_for_tournament(teams: true_dl_input.teams,
                                               number_of_questions: true_dl_input.questions_count)
      return if dl_value.nil?

      save_to_database(dl_value)
    end

    private

    def save_to_database(dl_value)
      existing_record = TrueDl.find_by(model_id: model.id, tournament_id:)
      if existing_record.present?
        if existing_record.true_dl.nil? || different_values?(existing_record.true_dl, dl_value)
          existing_record.update(true_dl: dl_value)
          Rails.logger.info "updated value for model #{model.name} and tournament ##{tournament_id}"
        else
          Rails.logger.info "value stayed the same for model #{model.name} and tournament ##{tournament_id}"
        end
      else
        TrueDl.create({ model_id: model.id, true_dl: dl_value, tournament_id: })
        Rails.logger.info "created value for model #{model.name} and tournament ##{tournament_id}"
      end
    end

    def different_values?(first, second)
      (first - second).abs > 0.0001
    end

    def fetch_data_for_true_dl
      tournament = model.tournament_details(tournament_id:)
      if tournament.questions_count.blank?
        Rails.logger.info "no questions data for the tournament ##{tournament_id}"
        return
      end

      tournament_results = model.tournament_results(tournament_id:)
      if tournament_results_invalid?(tournament_results)
        Rails.logger.info "no results for the tournament ##{tournament_id}"
        return
      end

      rankings = model.teams_ranking(list_of_team_ids: tournament_results.map(&:team_id), date: tournament.start)
      if rankings.blank?
        Rails.logger.info "no rankings for teams in the tournament ##{tournament_id}"
        return
      end

      teams = join_results_and_rankings(tournament_results, rankings)

      TrueDLInput[teams:, questions_count: tournament.questions_count]
    end

    def join_results_and_rankings(tournament_results, rankings)
      tournament_results.map do |result|
        next if rankings[result.team_id].blank?

        { points: result.points, ranking: rankings[result.team_id].first['place'] }
      end.compact
    end

    def tournament_results_invalid?(tournament_results)
      return true if tournament_results.blank?

      places = tournament_results.map(&:place)
      return true if places.compact.empty?
      return true if places.min >= 9999

      false
    end
  end
end
