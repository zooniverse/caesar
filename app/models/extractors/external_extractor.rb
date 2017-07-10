require 'uri'

module Extractors
  class ExternalExtractor < Extractor
    config :url, default: nil

    def process(classification)
      if url
        response = RestClient.post(url.to_s, classification.to_json, {content_type: :json, accept: :json})
        JSON.parse(response.body)
      else
        {}
      end
    end

    def url
      return nil unless config['url'].present?

      @url ||= URI(config['url'])
    end
  end
end
