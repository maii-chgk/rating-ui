require "test_helper"
require "minitest/autorun"

class TeamReleasePageTest < ActionDispatch::IntegrationTest
  include Capybara::DSL

  def assert_row_has_correct_team(row, expected_place, expected_team, expected_city, expected_rating)
    place, team, city, rating = row
    assert_equal place, expected_place
    assert_equal team, expected_team
    assert_equal city, expected_city
    assert_equal rating, expected_rating
  end

  def latest_release_teams
    {
      1 => ["1", "Борский корабел", "Москва", "14825\n+48"],
      21 => ["21 ↑4", "Метасеквоя", "Минск", "11283\n+215"],
      98 => ["98 ↓1", "Black Label", "Таллинн", "9356"]
    }
  end

  test "latest release is shown by default" do
    visit "/"

    assert_selector "#releases_" do
      options = all("option").map(&:text)
      assert_equal ["29 февраля 2024 года", "22 февраля 2024 года"], options
    end

    assert_equal "29 февраля 2024 года", find("select#releases_ option[selected]").text
  end

  test "table for the latest release has correct data" do
    visit "/"

    latest_release_teams.each do |place, team|
      assert_row_has_correct_team(all("table tr:nth-child(#{place}) td").map(&:text), *team)
    end

    assert_selector "table tbody tr", count: 100
  end

  test "release can be opened by its id" do
    visit "/b/132"

    latest_release_teams.each do |place, team|
      assert_row_has_correct_team(all("table tr:nth-child(#{place}) td").map(&:text), *team)
    end

    assert_selector "table tbody tr", count: 100
  end
end
