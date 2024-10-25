class TournamentResult < ApplicationRecord
  self.primary_key = "id"
  belongs_to :tournament
end
