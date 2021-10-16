class Api::V1::TeamsController < ApplicationController
  include InModel

  TEAMS_PER_PAGE = 500

  def show
    @release_id = params[:release_id]
    teams = current_model.teams_for_release_api(release_id: @release_id, limit: TEAMS_PER_PAGE, offset: offset)
    render json: metadata.merge({ items: teams }), status: 200
  end

  def clean_params
    params.permit(:model, :release_id, :page)
  end

  def page
    (clean_params[:page] || 1).to_i
  end

  def offset
    (page - 1) * TEAMS_PER_PAGE
  end

  def metadata
    {
      model: current_model.name,
      release_id: @release_id,
      current_page: page,
      teams_in_release: teams_in_release
    }
  end

  def teams_in_release
    current_model.count_all_teams_in_release(release_id: @release_id)
  end
end
