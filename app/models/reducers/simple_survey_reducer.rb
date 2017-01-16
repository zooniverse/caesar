module Reducers
  class SimpleSurveyReducer
    attr_reader :sub_ranges

    def initialize(id, config = {})
      @config = config
    end

    def process(extractions)
      ReductionResults.build do |results|
        process_range(results, extractions, "survey-total")

        sub_ranges.each do |range|
          from = range.fetch(:from)
          till = range.fetch(:till)
          process_range(results, extractions[from..till], "survey-from#{from}to#{till}")
        end
      end
    end

    private

    def process_range(results, extractions, key_prefix)
      extractions.each do |extraction|
        extraction.fetch("choices").each do |choice|
          results.increment("#{key_prefix}-#{choice}")
        end
      end
    end

    def sub_ranges
      @config["sub_ranges"] || [{from: 0, till: 2}]
    end
  end
end
