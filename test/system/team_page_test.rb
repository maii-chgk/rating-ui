require "test_helper"
require "minitest/autorun"

class TeamPageTest < ActionDispatch::IntegrationTest
  include ActiveRecord::TestFixtures
  include Capybara::DSL

  fixtures :seasons, :teams, :players, :towns

  def setup

  end

  def team_url(team_id)
    "/b/team/#{team_id}"
  end

  test "team page has its name and link to rating.chgk.info" do
    team = teams(:team_8)
    visit team_url(team.id)

    assert_text team.name
    assert_equal "Страница на rating.chgk.info", find_link(href: "https://rating.chgk.info/teams/#{team.id}").text
  end

  test "team page has its base roster" do
    team = teams(:team_8)
    visit team_url(team.id)

    season_title = if Time.zone.today.month >= 9
      "#{Time.zone.today.year}/#{(Time.zone.today.year + 1).to_s.last(2)}"
    else
      "#{Time.zone.today.year - 1}/#{Time.zone.today.year.to_s.last(2)}"
    end
    assert_text "Базовый состав на сезон #{season_title}"

    players = find("div.bg-gray-200 > div:nth-child(1)").all("p a")
    assert_equal ["Александра Брутер", "Максим Руссо"], players.map(&:text)
    assert_equal "/b/player/4270/", players.first[:href]
  end
end
