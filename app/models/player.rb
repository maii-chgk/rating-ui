class Player < ApplicationRecord
  self.primary_key = "id"

  def full_name
    "#{first_name} #{last_name}"
  end
end
