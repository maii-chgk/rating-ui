class Model < ApplicationRecord
  include TournamentQueries, TeamQueries, ReleaseQueries, PlayerQueries

  def cache_namespace
    name
  end
end
