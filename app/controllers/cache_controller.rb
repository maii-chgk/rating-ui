# frozen_string_literal: true

class CacheController < ApplicationController
  def reset
    Rails.cache.clear
    redirect_to :root
  end
end
