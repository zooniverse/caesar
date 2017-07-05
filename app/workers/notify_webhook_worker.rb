require 'uri'

class NotifyWebhookWorker
  include Sidekiq::Worker

  def perform(endpoint, event_name, data)
    return if endpoint.nil? or endpoint.empty?

    url = URI.parse(endpoint)
    new_args = URI.decode_www_form(url.query || '') << ["event_type", event_name]
    url.query = URI.encode_www_form(new_args)

    req = Net::HTTP::Post.new(url, 'Content-Type' => 'application/json')
    req.body = [data].to_json

    Net::HTTP.start(url.hostname, url.port) do |http|
      http.request(req)
    end
  end
end
