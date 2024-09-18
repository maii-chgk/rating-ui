require "test_helper"
require "minitest/autorun"

class TeamPageTest < ActionDispatch::IntegrationTest
  include Capybara::DSL

  def most_recent_september_1st
    today = Time.zone.today
    year = (today.month >= 9) ? today.year : today.year - 1
    Time.zone.local(year, 9, 1)
  end

  def setup
    season_id = 500
    season_start_date = most_recent_september_1st
    season_end_date = season_start_date + 1.year - 1.day
    start_date = season_start_date + 1.day
    season_query = <<~SQL
      insert into seasons (id, start, "end") 
      values (#{season_id}, '#{season_start_date.strftime("%Y-%m-%d")}', '#{season_end_date.strftime("%Y-%m-%d")}');
    SQL
    ActiveRecord::Base.connection.exec_query(season_query)

    roster_query = <<~SQL
      insert into base_rosters (player_id, team_id, start_date, season_id)
      values (4270, #{team_id}, '#{start_date.strftime("%Y-%m-%d")}', #{season_id}),
             (27403, #{team_id}, '#{start_date.strftime("%Y-%m-%d")}', #{season_id});
    SQL
    ActiveRecord::Base.connection.exec_query(roster_query)
  end

  def team_id
    62868
  end

  def team_url
    "/b/team/#{team_id}/"
  end

  test "team page has its name and link to rating.chgk.info" do
    visit team_url

    assert_text "Gay Guerrilla (сборная)"
    assert_equal "Страница на rating.chgk.info", find_link(href: "https://rating.chgk.info/teams/#{team_id}").text
  end

  test "team page has its base roster" do
    visit team_url

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
