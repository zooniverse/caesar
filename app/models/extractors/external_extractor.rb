module Extractors
  class ExternalExtractor < Extractor
    def process(classification)
      return {}

      # TODO: If URL configured, send classification there
    end

    def url
      config.fetch
    end
  end
end
