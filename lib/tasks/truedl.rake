# frozen_string_literal: true

require 'true_dl'

TrueDLInput = Data.define(:teams, :questions_count)

def fetch_data_for_true_dl(model, tournament_id)
  tournament = model.tournament_details(tournament_id:)
  if tournament.name.blank?
    puts "no data for the tournament ID ##{tournament_id}"
    return
  end

  tournament_results = model.tournament_results(tournament_id:)
  rankings = model.teams_ranking(list_of_team_ids: tournament_results.map(&:team_id), date: tournament.start)

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
      return
    end

    tournament_id = args[:id]
    true_dl_input = fetch_data_for_true_dl(model, tournament_id)

    dl_value = TrueDL.true_dl_for_tournament(teams: true_dl_input.teams,
                                             number_of_questions: true_dl_input.questions_count)

    existing_record = TrueDl.find_by(model_id: model.id, tournament_id:)
    if existing_record.present?
      existing_record.update(true_dl: dl_value) unless (existing_record.true_dl - dl_value).abs < 0.0001
      puts "updated value for model #{model.name} and tournament ##{tournament_id}"
    else
      TrueDl.create({ model_id: model.id, true_dl: dl_value, tournament_id:})
      puts "created value for model #{model.name} and tournament ##{tournament_id}"
    end
  end
end
