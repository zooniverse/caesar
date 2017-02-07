module Reducers
  class SimpleSurveyReducer < Reducer
    attr_reader :sub_ranges

    def process(extractions)
      ReductionResults.build do |results|
        first_n = filter_extracts(extractions)
        process_range(results, extractions, "survey-total")
        process_range(results, first_n, "survey-filtered")
      end
    end

    private

    def process_range(results, extractions, key_prefix)
      extractions.each do |extraction|
        extraction.data.fetch("choices").each do |choice|
          results.increment("#{key_prefix}-#{choice}")
        end
      end
    end

    def subranges
      config["subranges"] || [{from: 0, to: 2}]
    end
  end
end
