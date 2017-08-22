require 'uri'

module Reducers
  class ExternalReducer < Reducer
    config :url, default: nil

    def reduction_data_for(extractions)
      if url
        response = RestClient.post(url.to_s, extractions.to_json, {content_type: :json, accept: :json})

        if response.code==204
          Reducer.NoData
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
      return nil unless config['url'].present?

      @url ||= URI(config['url'])
    end
  end
end
