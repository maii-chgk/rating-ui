class AddTeamIdToTrueDls < ActiveRecord::Migration[7.2]
  def change
    add_column :true_dls, :team_id, :integer
  end
end
