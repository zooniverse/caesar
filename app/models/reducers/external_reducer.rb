require 'uri'

module Reducers
  class ExternalReducer < Reducer
    def process(extractions)
      if url
        req = Net::HTTP::Post.new(url, 'Content-Type' => 'application/json')
        req.body = extractions.to_json
        res = Net::HTTP.start(url.hostname, url.port) do |http|
          http.request(req)
        end
        JSON.parse(res.body)
      else
        {}
      end
    end

    def url
      return nil unless config.key?('url')

      @url ||= URI(config['url'])
    end
  end
end
