module Extractors
  module HttpExtraction
    include HttpOperation
    def self.included(base)
      HttpOperation.configure_validation(base)
    end

    class ExtractionFailed < HttpOperation::HttpOperationException; end

    def no_data
      Extractor::NoData
    end

    def operation_failed_type
      ExtractionFailed
    end

    def http_extract(classification)
      http_post(classification)
    end
  end
end
