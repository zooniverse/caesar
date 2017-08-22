require 'uri'

module Extractors
  class ExternalExtractor < Extractor
    config :url, default: nil

    def process(classification)
      if url
        response = RestClient.post(url.to_s, classification.to_json, {content_type: :json, accept: :json})

        if response.code==204
          Extractor.NoData
        elsif ([200, 201, 202].include? response.code) and response.body.present?
          JSON.parse(response.body)
        else
          raise StandardError.new 'Remote extractor failed'
        end
      else
        raise StandardError.new "External extractor improperly configured: no URL"
      end
    end

    def url
      return nil unless config['url'].present?

      @url ||= URI(config['url'])
    end
  end
end
