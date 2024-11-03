class Town < ApplicationRecord
  has_many :teams, dependent: :destroy
  self.primary_key = "id"
end
