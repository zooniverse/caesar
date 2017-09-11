require 'uri'

module Extractors
  class ExternalExtractor < Extractor
    validate do
      if config['url'].present?
        schemes = ['https']

        begin
          uri = URI.parse(config['url'])
          unless uri && uri.host && schemes.include?(uri.scheme)
            errors.add(:url, "URL must be one of: #{schemes.join(",")}")
          end
        rescue URI::InvalidURIError
          errors.add(:url, "URL could not be parsed")
        end
      end
    end

    def extract_data_for(classification)
      if url
        response = RestClient.post(url.to_s, classification.to_json, {content_type: :json, accept: :json})

        if response.code==204
          Extractor::NoData
        elsif ([200, 201, 202].include? response.code) and response.body.present?
          JSON.parse(response.body)
        else
          raise StandardError.new 'Remote extractor failed'
        end
      else
        raise StandardError.new "External extractor improperly configured: no URL"
      end
    end

    private

    def url
      return nil unless config['url'].present?

      @url ||= URI(config['url'])
    end
  end
end
