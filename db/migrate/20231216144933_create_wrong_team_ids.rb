class CreateWrongTeamIds < ActiveRecord::Migration[7.1]
  def change
    create_table :wrong_team_ids do |t|
      t.integer :tournament_id
      t.integer :old_team_id
      t.integer :new_team_id
      t.datetime :updated_at
    end
  end
end
