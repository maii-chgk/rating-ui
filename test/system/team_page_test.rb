require "test_helper"
require "minitest/autorun"

class TeamPageTest < ActionDispatch::IntegrationTest
  include Capybara::DSL

  def team_url
    "/b/team/49804"
  end

  test "team page has its name and link to rating.chgk.info" do
    visit team_url

    assert_text "Борский корабел (Москва)"
    assert_equal "Страница на rating.chgk.info", find_link(href: "https://rating.chgk.info/teams/49804").text
  end

  test "team page has its base roster" do
    visit team_url
    assert_text "Базовый состав на сезон 2023/24"

    players = find("div.bg-gray-200 > div:nth-child(1)").all("p a")
    assert_equal ["Александра Брутер", "Максим Руссо", "Дмитрий Сахаров", "Иван Семушин", "Сергей Спешков"],
      players.map(&:text)
    assert_equal "/b/player/4270/", players.first[:href]
  end
end
