require_relative "../lib/truedl_calculator"

class TrueDLForMAIITournamentsJob < ApplicationJob
  queue_as :default

  def perform(model_name)
    TrueDLCalculator.calculate_for_all_maii_tournaments(model_name:)
  end
end
