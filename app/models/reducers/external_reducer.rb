require 'uri'

module Reducers
  class ExternalReducer < Reducer
    class ExternalReducerFailed < StandardError; end

    config_field :url, default: nil
    config_field :version, default: 1

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

    def reduce_into(extractions, reduction)
      if url
        response = if default_reduction?
          RestClient.post(url, extractions.to_json, {content_type: :json, accept: :json})
        elsif running_reduction?
          RestClient.post(url, { extracts: extractions, store: reduction.store }.to_json, {content_type: :json, accept: :json})
        else
          raise StandardError.new("Impossible reducer configuration #{id}")
        end

        reduction.tap do |r|
          r.data = (if response.code == 204
            nil
          elsif ([200, 201, 202].include? response.code) and response.body.present?
            JSON.parse(response.body)
          else
            raise StandardError.new 'Remote reducer failed'
          end)

          if r&.data&.key? '_store'
            r.store = r.data['_store']
            r.data = r.data.except '_store'
          end
        end
      else
        raise StandardError.new "External extractor improperly configured: no URL"
      end
    rescue RestClient::InternalServerError
      raise ExternalReducerFailed
    end
  end
end