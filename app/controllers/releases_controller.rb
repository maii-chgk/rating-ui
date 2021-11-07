class ReleasesController < ApplicationController
  include InModel

  def show
    id = clean_params[:release_id] || current_model&.latest_release_id
    return render_404 if id.nil?

    teams = current_model.teams_for_release(release_id: id, from: from, to: to, city: city)
    @release = ReleasePresenter.new(id: id, teams: teams)

    all_teams_count = current_model.count_all_teams_in_release(release_id: id, city: city)
    @paging = Paging.new(items_count: all_teams_count, from: from, to: to)

    @filtered = city.present?

    @releases_in_dropdown = list_releases_for_dropdown
    @model_name = current_model.name
  end

  def clean_params
    params.permit(:model, :release_id, :from, :to, :name, :city)
  end

  def from
    (clean_params[:from] || 1).to_i
  end

  def to
    (clean_params[:to] || 100).to_i
  end

  def city
    @city = clean_params[:city]
  end

  def list_releases_for_dropdown
    current_model.all_releases.map do |release|
      [
        I18n.l(release["date"].to_date),
        release_path(release_id: release["id"], city: city)
      ]
    end
  end
end
