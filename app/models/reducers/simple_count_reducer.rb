module Reducers
  class SimpleCountReducer < Reducer
    def process(extracts)
      extracts.size
    end
  end
end
