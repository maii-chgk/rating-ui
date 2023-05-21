# frozen_string_literal: true

module ApplicationHelper
  def round_place(place)
    place.to_i == place ? place.to_i : place.to_s.gsub('.', ',')
  end
end
