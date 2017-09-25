require 'uri'

module Extractors
  class ExternalExtractor < Extractor
    config_field :url, default: nil

    validate do
      if url.present?
        schemes = ['https']

        begin
          uri = URI.parse(url)
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
        response = RestClient.post(url, classification.to_json, {content_type: :json, accept: :json})

        if response.code == 204
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
  end
end
