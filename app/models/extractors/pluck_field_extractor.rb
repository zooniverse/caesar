require 'jsonpath'

module Extractors
  class PluckFieldExtractor < Extractor
    class FailedMatch < StandardError; end

    config :path
    config :name
    config :if_missing, default: "error"

    def process(classification)
      evaluator = JsonPath.new path
      result = evaluator.on(classification.attributes)

      {}.tap do |hash|
        if result.size == 0
          if if_missing=="error"
            raise FailedMatch.new
          end
        elsif result.size==1
          hash[name] = result[0]
        else
          hash[name] = result
        end
      end

    end

    private

    def path
      config["path"]
    end

    def name
      config["name"]
    end

    def if_missing
      config["if_missing"]
    end
  end
end
