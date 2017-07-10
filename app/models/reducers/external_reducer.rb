require 'uri'

module Reducers
  class ExternalReducer < Reducer
    config :url, default: nil

    def reduction_data_for(extractions)
      if url
        response = RestClient.post(url.to_s, extractions.to_json, {content_type: :json, accept: :json})
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
