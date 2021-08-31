class CacheController < ApplicationController
  def reset
    Rails.cache.clear
    head :ok
  end
end
