# frozen_string_literal: true

class HealthcheckController < ApplicationController
  def ping
    head :ok
  end
end
