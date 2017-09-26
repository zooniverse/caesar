require 'redis'

if Rails.env.development? || Rails.env.staging? || Rails.env.production?
  redis = Redis.new
  data_store = Stoplight::DataStore::Redis.new(redis)
  Stoplight::Light.default_data_store = data_store
end
