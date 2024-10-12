class AddTeamIdToTrueDls < ActiveRecord::Migration[7.2]
  def change
    add_column :true_dls, :team_id, :integer
    add_index :true_dls, [:model_id, :team_id, :tournament_id], unique: true
  end
end
