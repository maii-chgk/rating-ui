class ReleasesController < ApplicationController
  DEFAULT_MODEL = "b".freeze

  def show
    @model_id = current_model.id
    @release_id = params[:release_id]
    @teams = current_model.all_teams_for_release(@release_id)
  end

  def latest
    @teams = current_model.all_teams_for_latest_release
    render :show
  end

  def current_model
    Model.find_by(name: params[:model] || DEFAULT_MODEL)
  end
end
