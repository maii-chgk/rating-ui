class ReleasesController < ApplicationController
  DEFAULT_MODEL = "b".freeze

  def show
    @release_id = params[:release_id].to_i
    render_release
  end

  def latest
    @release_id = current_model.latest_release_id
    render_release
  end

  def render_release
    @model_name = current_model.name
    all_releases = current_model.all_releases
    @release_date = all_releases.find { |r| r['id'] == @release_id }['date']
    @releases_in_dropdown = all_releases.map(&:values)
    @teams = current_model.all_teams_for_release(@release_id)
    render :show
  end

  def current_model
    Model.find_by(name: params[:model] || DEFAULT_MODEL)
  end
end
