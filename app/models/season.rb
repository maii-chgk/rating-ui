class Season < ApplicationRecord
  self.primary_key = "id"

  def self.current_season
    Season.where('current_date between "start" and "end"').first
  end

  def title
    "#{start.strftime("%Y")}/#{self.end.strftime("%y")}"
  end
end
