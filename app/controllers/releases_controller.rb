class ReleasesController < ApplicationController
  before_action :force_trailing_slash

  include InModel

  def show
    id = clean_params[:release_id] || current_model.latest_release_id
    teams = current_model.teams_for_release(release_id: id, top_place: top_place, bottom_place: bottom_place)
    all_teams_count = current_model.count_all_teams_in_release(release_id: id)
    @release = ReleasePresenter.new(id: id, teams: teams, teams_in_release_count: all_teams_count)

    @releases_in_dropdown = list_releases_for_dropdown
    @model_name = current_model.name
  end

  def clean_params
    params.permit(:model, :release_id, :from, :to)
  end

  def top_place
    @top_place = (clean_params[:from] || 1).to_i
  end

  def bottom_place
    @bottom_place = (clean_params[:to] || 100).to_i
  end

  def list_releases_for_dropdown
    current_model.all_releases.map do |release|
      [
        I18n.l(release["date"].to_date),
        release_path(release_id: release["id"])
      ]
    end
  end
end
