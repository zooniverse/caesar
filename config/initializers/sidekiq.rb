require 'sidekiq/web'
Sidekiq::Logstash.setup

Sidekiq.configure_server do |config|
  config.average_scheduled_poll_interval = 1
end