SIDEKIQ_REDIS_URL = ENV["SIDEKIQ_REDIS_URL"] || "redis://localhost:6379/0"

Sidekiq.configure_server do |config|
  config.redis = {url: SIDEKIQ_REDIS_URL}
end

Sidekiq.configure_client do |config|
  config.redis = {url: SIDEKIQ_REDIS_URL}
end
