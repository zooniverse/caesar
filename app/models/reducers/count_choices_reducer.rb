module Reducers
  class CountChoicesReducer < Reducer
    attr_reader :sub_ranges

    def reduction_data_for(extractions)
      CountingHash.build do |results|
        extractions.each do |extraction|
          results.increment(extraction.data["value"],1)
        end
      end
    end
  end
end
