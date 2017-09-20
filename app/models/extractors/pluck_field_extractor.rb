require 'json'
require 'jsonpath'

class String
  def parse_json
    JSON.parse(self)
  end
end

module Extractors
  class PluckFieldExtractor < Extractor
    class FailedMatch < StandardError; end

    validates :field_map, presence: true
    validates :if_missing, presence: true

    def extract_data_for(classification)
      Hash.new.tap do |hash|
        field_map.each do |name, path|
          hash[name] = extract_one(classification, path)
        end
      end
    end

    def extract_one(classification, details)
      if(details.class == String)
        path = details
        after = "itself"
      else
        path = details["path"]
        after = details["transform"]
      end

      evaluator = JsonPath.new path
      result = evaluator.on(classification.prepare)

      if result.size == 0
        if if_missing=="error"
          raise FailedMatch.new
        else
          nil
        end
      elsif result.size==1
        result[0].send(after)
      else
        result.send(after)
      end

    end

    private

    def field_map
      config["field_map"]
    end

    def if_missing
      config.fetch("if_missing", "error")
    end
  end
end
