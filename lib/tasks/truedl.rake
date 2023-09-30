# frozen_string_literal: true

require 'true_dl'

TrueDLInput = Data.define(:teams, :questions_count)

def tournament_results_invalid?(tournament_results)
  return true if tournament_results.blank?

  places = tournament_results.map(&:place)
  return true if places.compact.empty?
  return true if places.min >= 9999

  false
end

def fetch_data_for_true_dl(model, tournament_id)
  tournament = model.tournament_details(tournament_id:)
  if tournament.name.blank?
    puts "no data for the tournament ##{tournament_id}"
    return
  end

  tournament_results = model.tournament_results(tournament_id:)

  if tournament_results_invalid?(tournament_results)
    puts "no results for the tournament ##{tournament_id}"
    return
  end

  rankings = model.teams_ranking(list_of_team_ids: tournament_results.map(&:team_id), date: tournament.start)
  if rankings.blank?
    puts "no rankings for teams in the tournament ##{tournament_id}"
    return
  end

  teams = tournament_results.map do |result|
    next if rankings[result.team_id].blank?

    { points: result.points, ranking: rankings[result.team_id].first['place'] }
  end.compact

  TrueDLInput[teams:, questions_count: tournament.questions_count]
end

namespace :true_dl do
  task :calculate_for_tournament, %i[id model] => :environment do |_t, args|
    model = Model.find_by(name: args[:model])
    unless model
      puts "no model with the name #{args[:model]}}"
      next
    end

    tournament_id = args[:id]
    true_dl_input = fetch_data_for_true_dl(model, tournament_id)
    next unless true_dl_input

    dl_value = TrueDL.true_dl_for_tournament(teams: true_dl_input.teams,
                                             number_of_questions: true_dl_input.questions_count)
    next if dl_value.nil?

    existing_record = TrueDl.find_by(model_id: model.id, tournament_id:)
    if existing_record.present?
      if existing_record.true_dl.nil? || (existing_record.true_dl - dl_value).abs > 0.0001
        existing_record.update(true_dl: dl_value)
        puts "updated value for model #{model.name} and tournament ##{tournament_id}"
      else
        puts "value stayed the same for model #{model.name} and tournament ##{tournament_id}"
      end

    else
      TrueDl.create({ model_id: model.id, true_dl: dl_value, tournament_id:})
      puts "created value for model #{model.name} and tournament ##{tournament_id}"
    end
  end

  task :calculate_for_all_maii_tournaments, [:model] => :environment do |_t, args|
    model = Model.find_by(name: args[:model])
    unless model
      puts "no model with the name #{args[:model]}}"
      next
    end

    tournaments = model.all_tournaments_after_date(date: '2021-09-01')
    puts "calculating truedl for #{tournaments.size} tournaments"

    tournaments.each_with_index do |tournament, index|
      Rake::Task['true_dl:calculate_for_tournament'].invoke(tournament['id'], model.name)
      Rake::Task['true_dl:calculate_for_tournament'].reenable
      puts "progress: #{index + 1}/#{tournaments.size}" if (index + 1) % 10 == 0
    end
  end
end
