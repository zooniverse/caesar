require 'jsonpath'

module Extractors
  class PluckFieldExtractor < Extractor
    class FailedMatch < StandardError; end
    class NoMatches < StandardError; end

    config_field :field_map
    config_field :if_missing, default: 'error', enum: ['error', 'ignore', "reject"]

    def extract_data_for(classification)
      Hash.new.tap do |hash|
        field_map.each do |name, path|
          hash[name] = extract_one(classification, path)
        end
      end
    rescue FailedMatch
      if if_missing == "reject"
        Extractor::NoData
      else
        raise
      end
    end

    def extract_one(classification, path)
      evaluator = JsonPath.new path
      result = evaluator.on(classification.prepare)

      case result.size
      when 0
        if if_missing == "ignore"
          nil
        else
          raise FailedMatch
        end
      when 1
        result[0]
      else
        result
      end
    end
  end
end
