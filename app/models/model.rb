class Model < ApplicationRecord
  include TournamentQueries, TeamQueries, ReleaseQueries, PlayerQueries
end
