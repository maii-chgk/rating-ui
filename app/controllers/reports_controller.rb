class ReportsController < ActionController::Base
  include ReportsQueries

  def mau
    @data = active_rating_players.map { |month| {x: month.month, y: month.count}}.to_json
    render layout: "reports"
  end
end
