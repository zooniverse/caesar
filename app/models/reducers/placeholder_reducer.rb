module Reducers
  class PlaceholderReducer < Reducer
    def reduce_into(extracts, reduction)
      reduction.tap do |r|
        r.data = nil
      end
    end
  end
end
