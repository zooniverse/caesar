module Reducers
  class FirstExtractReducer < Reducer
    def reduction_data_for(extractions, reduction)
      extractions&.fetch(0, nil)&.data || {}
    end
  end
end
