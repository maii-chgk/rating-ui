require "test_helper"
require "minitest/autorun"

class TeamReleaseSearchTest < ActionDispatch::IntegrationTest
  include Capybara::DSL

  def assert_guerrilla_found
    assert_selector "table tbody tr", count: 1

    within "table" do
      assert_selector "tr", text: "Gay Guerrilla"
      assert_selector "tr", text: "13464"
      assert_selector "tr", text: "+255"
    end
  end

  test "release can be searched by a team’s name" do
    visit "/"
    fill_in "team", with: "gay"
    click_on("Поиск")
    assert_guerrilla_found
  end

  test "release can be searched by any part of a team’s name" do
    visit "/"
    fill_in "team", with: "guerr"
    click_on("Поиск")

    assert_guerrilla_found
  end

  test "asterisk can be used in search" do
    visit "/"
    fill_in "team", with: "*guerr*"
    click_on("Поиск")

    assert_guerrilla_found
  end

  test "release can be searched by city" do
    visit "/"
    fill_in "city", with: "минск"
    click_on("Поиск")

    assert_selector "table tbody tr", count: 43

    city_column_values = all("table tr td:nth-child(4)").map(&:text).uniq
    assert_equal ["Минск"], city_column_values
  end
end
