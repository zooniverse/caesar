# Reducers::FirstExtractReducer
#
# data: {
#   SHAPE OF FIRST MATCHING EXTRACT
#}
#
module Reducers
  class FirstExtractReducer < Reducer
    def reduction_data_for(extractions, reduction)
      if reduction&.data.blank? then (extractions&.fetch(0, nil)&.data || {}) else reduction.data end
    end
  end
end
