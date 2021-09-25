class PlayerReleasesController < ApplicationController
  before_action :force_trailing_slash

  include InModel

  def show
    @release_id = clean_params[:release_id] || current_model.latest_release_id
    @releases_in_dropdown = list_releases_for_dropdown

    @players = current_model.players_for_release(release_id: @release_id,
      top_place: top_place,
      bottom_place: bottom_place)

    @all_players_count = current_model.count_all_players_in_release(release_id: @release_id)

    @model_name = current_model.name
  end

  def clean_params
    params.permit(:model, :release_id, :from, :to)
  end

  def top_place
    @top_place = (clean_params[:from] || 1).to_i
  end

  def bottom_place
    @bottom_place = (clean_params[:to] || 250).to_i
  end

  def list_releases_for_dropdown
    current_model.all_releases.map do |release|
      [
        I18n.l(release["date"].to_date),
        player_release_path(release_id: release["id"])
      ]
    end
  end
end
