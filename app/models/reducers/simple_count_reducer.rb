module Reducers
  class SimpleCountReducer < Reducer
    def reduction_data_for(extracts)
      extracts.size
    end
  end
end
