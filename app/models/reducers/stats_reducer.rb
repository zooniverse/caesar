module Reducers
  class StatsReducer < Reducer
    def reduce_into(extractions, reduction, _relevant_reductions=[])
      data = reduction.data || {}

      reduction.tap do |r|
        r.data = CountingHash.build(data) do |results|
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
end
