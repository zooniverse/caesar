module Reducers
  class CountChoicesReducer < Reducer
    attr_reader :sub_ranges

    def reduction_data_for(extractions)
      ReductionResults.build do |results|
        extractions.each do |extraction|
          results.increment(extraction.data,1)
        end
      end
    end
  end
end
