module Reducers
  class PlaceholderReducer < Reducer
    def reduce_into(extracts, reduction, _relevant_reductions=[])
      reduction.tap do |r|
        r.data = nil
      end
    end
  end
end
