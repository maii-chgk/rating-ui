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
    @model_name = current_model.name
    all_releases = current_model.all_releases
    @release_date = all_releases.find { |r| r['id'] == @release_id }&['date']
    @releases_in_dropdown = all_releases.map(&:values)

    @teams = current_model.teams_for_release(release_id: @release_id,
      top_place: top_place,
      bottom_place: bottom_place)

    render :show
  end

  def current_model
    Model.find_by(name: params[:model] || DEFAULT_MODEL)
  end

  def clean_params
    params.permit(:release_id, :from, :to)
  end

  def top_place
    clean_params[:from] || 1
  end

  def bottom_place
    clean_params[:to] || 100
  end
end
