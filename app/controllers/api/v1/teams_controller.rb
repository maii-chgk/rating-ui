class Api::V1::TeamsController < ApiController
  include InModel

  def show
    @release_id = params[:release_id]
    teams = current_model.teams_for_release_api(release_id: @release_id, limit: PER_PAGE, offset: offset)
    Places::add_top_and_bottom_places!(teams)
    
    tournaments = current_model.tournaments_in_release_by_team(release_id: @release_id)
    teams.each do |team|
      team["tournaments"] = tournaments.fetch(team["team_id"], [])
    end

    render_paged_json(metadata: metadata, items: teams, all_items_count: teams_in_release)
  end

  def metadata
    {
      model: current_model.name,
      release_id: @release_id
    }
  end

  def teams_in_release
    current_model.count_all_teams_in_release(release_id: @release_id)
  end
end
