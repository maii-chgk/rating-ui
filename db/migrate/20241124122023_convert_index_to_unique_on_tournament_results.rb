class ConvertIndexToUniqueOnTournamentResults < ActiveRecord::Migration[7.2]
  def change
    remove_index :tournament_results, name: "tournament_results_team_id_tournament_id_index"
    add_index :tournament_results, [:team_id, :tournament_id], unique: true
  end
end
