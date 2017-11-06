Rails.application.config.tap do |config|
  config.lograge.enabled = true

  # add time to lograge
  config.lograge.custom_options = lambda do |event|
    { time: event.time }
  end

  config.lograge.formatter = Lograge::Formatters::Logstash.new
end