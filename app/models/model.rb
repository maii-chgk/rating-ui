# frozen_string_literal: true

class Model < ApplicationRecord
  include PlayerQueries
  include ReleaseQueries
  include TeamQueries
  include TournamentQueries

  def cache_namespace
    name
  end
end
