class Model < ApplicationRecord
  include Cacheable, TournamentQueries, TeamQueries, ReleaseQueries, PlayerQueries
end
