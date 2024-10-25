class Tournament < ApplicationRecord
  self.primary_key = "id"
  self.inheritance_column = nil
end
