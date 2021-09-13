require 'sidekiq/web'
require "sidekiq-unique-jobs"
Sidekiq::Logstash.setup


Sidekiq.configure_server do |config|
  config.redis = { url: ENV["REDIS_URL"] }

  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end

  config.server_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Server
  end

  SidekiqUniqueJobs::Server.configure(config)
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV["REDIS_URL"] }

  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end
end
