require 'jsonpath'

module Extractors
  class PluckFieldExtractor < Extractor
    class FailedMatch < StandardError; end

    validates :path, presence: true
    validates :name, presence: true
    validates :if_missing, presence: true

    def extract_data_for(classification)
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
      config.fetch("if_missing", "error")
    end
  end
end
