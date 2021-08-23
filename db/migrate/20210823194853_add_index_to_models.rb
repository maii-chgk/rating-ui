class AddIndexToModels < ActiveRecord::Migration[6.1]
  def change
    add_index :models, :name, unique: true
  end
end
