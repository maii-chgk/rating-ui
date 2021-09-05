class ReleasesController < ApplicationController
  before_action :force_trailing_slash, only: :latest

  DEFAULT_MODEL = "b".freeze

  def show
    @release_id = clean_params[:release_id].to_i
    render_release
  end

  def latest
    @release_id = current_model.latest_release_id
    render_release
  end

  def render_release
    all_releases = current_model.all_releases
    release = all_releases.find { |r| r['id'] == @release_id }
    @release_date = release['date'] unless release.nil?
    @releases_in_dropdown = all_releases.map(&:values)

    @teams = current_model.teams_for_release(release_id: @release_id,
      top_place: top_place,
      bottom_place: bottom_place)

    @all_teams_count = current_model.count_all_teams_in_release(release_id: @release_id)

    @model_name = current_model.name

    render :show
  end

  def current_model
    Model.find_by(name: params[:model] || DEFAULT_MODEL)
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
end
