# frozen_string_literal: true

class PlayerComponent < ViewComponent::Base
  def initialize(player:)
    @player = player
    flag = if @player.respond_to?(:flag)
      @player.flag
    elsif @player.respond_to?(:[])
      @player["flag"]
    end
    @bold = flag == "Б" || flag == "К"
    @italic = flag == "Л"
    @name = "#{@player.first_name}&nbsp;#{@player.last_name}"
  end

  def before_render
    return if @name.blank?

    @player_link = link_to(sanitize(@name),
      player_path(player_id: @player.player_id),
      class: "hover:underline text-sm")
  end

  def render?
    @player.present? && @name.present?
  end
end
