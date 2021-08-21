class ReleasesController < ApplicationController
  def show
    @model_name = current_model.name
    @teams = current_model.all_teams_for_release(params[:release_id])
  end

  def latest
    @teams = current_model.all_teams_for_latest_release
    render :show
  end

  def current_model
    Model.find_by(name: params[:model])
  end
end
