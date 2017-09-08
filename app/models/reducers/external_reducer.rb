require 'uri'

module Reducers
  class ExternalReducer < Reducer
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

    def reduction_data_for(extractions)
      if url
        response = RestClient.post(url.to_s, extractions.to_json, {content_type: :json, accept: :json})

        if response.code==204
          NoData
        elsif ([200, 201, 202].include? response.code) and response.body.present?
          JSON.parse(response.body)
        else
          raise StandardError.new 'Remote reducer failed'
        end
      else
        raise StandardError.new "External extractor improperly configured: no URL"
      end
    end

    def url
      return nil if config['url'].blank?

      @url ||= URI(config['url'])
    end
  end
end
