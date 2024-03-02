require "test_helper"
require "minitest/autorun"

class VisitMainPageTest < ActionDispatch::IntegrationTest
  include Capybara::DSL

  test "latest release is shown with correct data" do
    visit "/"

    assert_selector "table"

    within "table" do
      assert_selector "tr", text: "Борский корабел"
      assert_selector "tr", text: "14825"
    end
  end
end
