class ReleasePresenter
  attr_reader :id, :teams, :teams_in_release_count

  def initialize(id:, teams:, teams_in_release_count:)
    @id = id
    @teams = teams
    @teams_in_release_count = teams_in_release_count
  end
end