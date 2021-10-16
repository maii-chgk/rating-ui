class Api::V1::PlayersController < ApiController
  include InModel

  def show
    @release_id = params[:release_id]
    players = current_model.players_for_release_api(release_id: @release_id, limit: PER_PAGE, offset: offset)
    render_json(metadata: metadata, items: players)
  end

  def metadata
    {
      model: current_model.name,
      release_id: @release_id,
      current_page: page,
      teams_in_release: players_in_release
    }
  end

  def players_in_release
    current_model.count_all_players_in_release(release_id: @release_id)
  end
end
