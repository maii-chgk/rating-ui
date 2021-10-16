class Api::V1::TeamsController < ApiController
  include InModel

  def show
    @release_id = params[:release_id]
    teams = current_model.teams_for_release_api(release_id: @release_id, limit: PER_PAGE, offset: offset)
    render_json(metadata: metadata, items: teams)
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
