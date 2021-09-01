class ReleasesController < ApplicationController
  DEFAULT_MODEL = "b".freeze

  def show
    fetch_model_data!
    @release_id = params[:release_id].to_i
    @release_date = @all_releases.find { |r| r['id'] == @release_id }['date']
    @teams = current_model.all_teams_for_release(@release_id)
  end

  def latest
    fetch_model_data!
    @release_id, @release_date = current_model.latest_release.values_at("id", "date")
    @teams = current_model.all_teams_for_release(@release_id)
    render :show
  end

  def current_model
    Model.find_by(name: params[:model] || DEFAULT_MODEL)
  end

  def fetch_model_data!
    @model_name = current_model.name
    @all_releases = current_model.all_releases
  end
end
