Sidekiq.configure_server do |config|
  config.failures_max_count = 2000
end