Raven.configure do |config|
  config.dsn = ENV['SENTRY_DSN']

  config.current_environment = ENV['SENTRY_ENV'] || Rails.env
  config.sanitize_fields = ["credentials"]

  config.excluded_exceptions += ['ActionController::RoutingError',
                                'ActiveRecord::ConcurrentMigrationError',
                                'Stoplight::Error::RedLight',
                                'Extractors::ExternalExtractor::ExternalExtractorFailed',
                                'RestClient::GatewayTimeout',
                                'RestClient::BadGateway',
                                'Extractors::PluckFieldExtractor::FailedMatch',
                                'RunsReducers::ReductionConflict',
                                'Reducers::ExternalReducer::ExternalReducerFailed',
                                'Extractor::ExtractionFailed']
end
