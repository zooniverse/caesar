module Reducers
  class SimpleSurveyReducer < Reducer
    attr_reader :sub_ranges

    def reduction_data_for(extractions)
      ReductionResults.build do |results|
        extractions.each do |extraction|
          extraction.data.fetch("choices").each do |choice|
            results.increment(choice)
          end
        end
      end
    end
  end
end
