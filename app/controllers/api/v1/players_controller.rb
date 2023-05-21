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

    metadata = {
      model: current_model.name,
      release_id: release_id
    }

    render_paged_json(metadata: metadata, items: players, all_items_count: players_in_release_count)
  end

  def show
    return render_error_json(error: MISSING_MODEL_ERROR) if current_model.nil?

    releases = current_model.player_releases(player_id: player_id).map(&:to_h)
    tournaments = current_model.player_tournaments(player_id: player_id)

    tournaments_hash = tournaments.each_with_object({}) do |tournament, hash|
      next unless tournament.in_rating

      (hash[tournament["release_id"]] ||= []) << tournament.to_h.except(:release_id)
    end

    releases.each do |release|
      release["tournaments"] = tournaments_hash[release[:id]]
    end

    metadata = {
      model: current_model.name,
      player_id: player_id
    }

    render_json(metadata: metadata, items: releases)
  end

  def players_in_release_count
    current_model.count_all_players_in_release(release_id: release_id)
  end

  def release_id
    @release_id ||= if params[:release_id] == 'latest'
                      current_model.latest_release_id
                    else
                      params[:release_id]
                    end
  end

  def player_id
    @player_id ||= params[:player_id].to_i
  end
end
