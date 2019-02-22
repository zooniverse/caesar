module Extractors
  class ExternalExtractor < Extractor
    include Extractors::HttpExtraction

    class ExternalExtractorFailed < StandardError; end

    config_field :url, default: nil

    def extract_data_for(classification)
      http_extract(classification)
    rescue StandardError => e
      raise ExternalExtractorFailed.new e.to_s
    end
  end
end
