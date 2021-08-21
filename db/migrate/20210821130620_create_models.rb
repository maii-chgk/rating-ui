class CreateModels < ActiveRecord::Migration[6.1]
  def change
    create_table :models do |t|
      t.text :name
      t.boolean :changes_teams
      t.boolean :changes_rosters

      t.timestamps
    end
  end
end
