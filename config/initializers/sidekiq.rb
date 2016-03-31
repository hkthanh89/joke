def set_redis_config
  if Rails.env.production?
    { url: 'redis://127.0.0.1:6379/12', namespace: "jokee" }
  else
    { url: 'redis://localhost:6379/12', namespace: "jokee" }
  end
end

Sidekiq.configure_server do |config|
  config.failures_max_count = 2000
  config.redis = set_redis_config
end

Sidekiq.configure_client do |config|
  config.redis = set_redis_config
end