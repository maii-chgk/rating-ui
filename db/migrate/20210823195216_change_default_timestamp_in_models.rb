class ChangeDefaultTimestampInModels < ActiveRecord::Migration[6.1]
  def change
    change_column_default :models, :created_at, from: nil, to: ->{ 'current_timestamp' }
    change_column_default :models, :updated_at, from: nil, to: ->{ 'current_timestamp' }
  end
end
