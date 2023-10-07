class CreateTrueDls < ActiveRecord::Migration[7.0]
  def change
    create_table :true_dls do |t|
      t.integer :tournament_id
      t.float :true_dl
      t.references :model, null: false, foreign_key: true

      t.timestamps
    end
  end
end
