class Api::V1::PlayersController < ApiController
  include InModel

  def release
    return render_error_json(error: MISSING_MODEL_ERROR) if current_model.nil?

    players = current_model.players_for_release_api(release_id: release_id, limit: PER_PAGE, offset: offset)
    Places::add_top_and_bottom_places!(players)
    Places::add_previous_top_and_bottom_places!(players)

    tournaments = current_model.player_ratings_for_release(release_id: release_id)
    players.each do |player|
      player["tournaments"] = tournaments.fetch(player["player_id"], [])
    end

    render_paged_json(metadata: metadata, items: players, all_items_count: players_in_release)
  end

  def metadata
    {
      model: current_model.name,
      release_id: release_id
    }
  end

  def players_in_release
    current_model.count_all_players_in_release(release_id: release_id)
  end

  def release_id
    @release_id ||= if params[:release_id] == 'latest'
                      current_model.latest_release_id
                    else
                      params[:release_id]
                    end
  end
end
