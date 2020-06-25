Raven.configure do |config|
  config.dsn = ENV['SENTRY_DSN']

  config.current_environment = ENV['SENTRY_ENV'] || Rails.env
  config.sanitize_fields = ["credentials"]
end
