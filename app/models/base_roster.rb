class BaseRoster < ApplicationRecord
  self.primary_key = "id"
  belongs_to :team
end
