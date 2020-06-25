# frozen_string_literal: true

Raven.configure do |config|
  # https://docs.sentry.io/clients/ruby/config/
  config.dsn = ENV['SENTRY_DSN']

  config.current_environment = ENV['SENTRY_ENV'] || Rails.env
  config.sanitize_fields = ["credentials"]

  config.excluded_exceptions << 'RestClient::BadRequest'
end
