# frozen_string_literal: true

class TrueDLCalculator
  TrueDLInput = Data.define(:teams, :questions_count)

  def self.calculate_for_tournament(tournament_id:, model_name:)
    TrueDLCalculator.new(tournament_id, model_name).run
  end

  def self.calculate_for_all_maii_tournaments(model_name:)
    model = Model.find_by(name: model_name)
    unless model
      Rails.logger.error "no model with the name #{model_name}"
      return
    end

    tournaments = model.all_tournaments_after_date(date: "2021-09-01")
    Rails.logger.info "calculating truedl for #{tournaments.size} tournaments"

    tournaments.each_with_index do |tournament, index|
      calculate_for_tournament(tournament_id: tournament["id"], model_name:)
      Rails.logger.info "Progress: #{index + 1}/#{tournaments.size}" if (index + 1) % 10 == 0
    end
  end

  attr_reader :tournament_id, :model

  def initialize(tournament_id, model_name)
    @model = Model.find_by(name: model_name)
    @tournament_id = tournament_id
  end

  def tournament
    @tournament ||= model.tournament_details(tournament_id:)
  end

  def date
    @date ||= tournament.start
  end

  def tournament_results
    @tournament_results ||= model.tournament_results(tournament_id:)
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
      TrueDl.create({model_id: model.id, true_dl: dl_value, tournament_id:})
      Rails.logger.info "created value for model #{model.name} and tournament ##{tournament_id}"
    end
  end

  def different_values?(first, second)
    (first - second).abs > 0.0001
  end

  def fetch_data_for_true_dl
    return if tournament.questions_count.blank?
    return if tournament_results_invalid?

    filter_by_continuity!
    return if tournament_results.empty?

    rankings = model.teams_ranking(team_ids: tournament_results.map(&:team_id), date:)
    return if rankings.blank?

    teams = join_results_and_rankings(rankings)

    TrueDLInput[teams:, questions_count: tournament.questions_count]
  end

  def filter_by_continuity!
    team_ids = tournament_results.map(&:team_id)
    tournament_rosters = model.tournament_players(tournament_id:)
    base_rosters = model.base_rosters_on_date(team_ids:, date:).pluck("player_id", "team_id")

    team_ids.each do |team_id|
      players = tournament_rosters[team_id].pluck("player_id")
      base_players = base_rosters.filter { |_, roster_id| roster_id == team_id }.map(&:first)
      next if RosterContinuity.has_continuity?(players:, base_players:, date:)

      tournament_results.delete_if { |result| result.team_id == team_id }
    end
  end

  def join_results_and_rankings(rankings)
    tournament_results.map do |result|
      next if rankings[result.team_id].blank?

      {points: result.points, ranking: rankings[result.team_id].first["place"]}
    end.compact
  end

  def tournament_results_invalid?
    return true if tournament_results.blank?

    places = tournament_results.map(&:place)
    return true if places.compact.empty?
    return true if places.min >= 9999

    false
  end
end
