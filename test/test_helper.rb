# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"

require "minitest"
require_relative "../config/environment"
require "rails/test_help"
require "capybara/rails"
Capybara.default_driver = :rack_test
