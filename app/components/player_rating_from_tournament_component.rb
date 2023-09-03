# frozen_string_literal: true

class PlayerRatingFromTournamentComponent < ViewComponent::Base
  include ApplicationHelper

  def initialize(player_rating_from_tournament:)
    @rating = player_rating_from_tournament
  end

  def single_line
    "#{@rating['current']} (#{@rating['initial']}) — #{@rating['tournament_title']} (#{round_place(@rating['position'])})"
      .gsub(' ', '&nbsp;')
      .html_safe
  end
end
