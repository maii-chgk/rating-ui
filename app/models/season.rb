class Season < ApplicationRecord
  self.primary_key = "id"

  FIRST_MAII_SEASON_START = Date.new(2021, 9, 1)

  def self.current_season
    Season.where('current_date between "start" and "end"').first
  end

  def title
    "#{start.strftime("%Y")}/#{self.end.strftime("%y")}"
  end
end
