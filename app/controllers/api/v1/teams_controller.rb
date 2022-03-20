class Api::V1::TeamsController < ApiController
  include InModel

  def release
    return render_error_json(error: MISSING_MODEL_ERROR) if current_model.nil?

    teams = current_model.teams_for_release_api(release_id: release_id, limit: PER_PAGE, offset: offset)
    Places::add_top_and_bottom_places!(teams)
    Places::add_previous_top_and_bottom_places!(teams)

    tournaments = current_model.tournaments_in_release_by_team(release_id: release_id)
    teams.each do |team|
      team["tournaments"] = tournaments.fetch(team["team_id"], [])
    end

    metadata = {
      model: current_model.name,
      release_id: release_id
    }

    render_paged_json(metadata: metadata, items: teams, all_items_count: teams_in_release)
  end

  def show
    return render_error_json(error: MISSING_MODEL_ERROR) if current_model.nil?

    teams_releases = current_model.team_releases(team_id: params[:team_id])

    metadata = {
      model: current_model.name,
      team_id: params[:team_id]
    }

    render_json(metadata: metadata, items: teams_releases)
  end

  def teams_in_release
    current_model.count_all_teams_in_release(release_id: release_id)
  end

  def release_id
    @release_id ||= if params[:release_id] == 'latest'
                      current_model.latest_release_id
                    else
                      params[:release_id]
                    end
  end
end
