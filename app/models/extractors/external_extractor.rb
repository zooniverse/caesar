require 'uri'

module Extractors
  class ExternalExtractor < Extractor
    def process(classification)
      if url
        req = Net::HTTP::Post.new(url, 'Content-Type' => 'application/json')
        req.body = classification.to_json
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
