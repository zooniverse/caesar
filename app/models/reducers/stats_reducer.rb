module Reducers
  class StatsReducer < Reducer
    def reduction_data_for(extractions)
      CountingHash.build do |results|
        extractions.each do |extraction|
          extraction.data.each do |key, value|
            case value
            when TrueClass, FalseClass
              results.increment(key, value ? 1 : 0)
            else
              results.increment(key, value)
            end
          end
        end
      end
    end
  end
end
