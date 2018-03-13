module Reducers
  class StatsReducer < Reducer
    def reduction_data_for(extractions, reduction)
      initial_value = {}
      initial_value = reduction.data if running_reduction? && reduction&.data.present?

      CountingHash.build(initial_value) do |results|
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
