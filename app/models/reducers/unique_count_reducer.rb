module Reducers
  class UniqueCountReducer < Reducer
    def process(extracts)
      extracts.uniq.size
    end
  end
end
