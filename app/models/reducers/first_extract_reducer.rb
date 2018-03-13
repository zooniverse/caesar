# Reducers::FirstExtractReducer
#
# data: {
#   SHAPE OF FIRST MATCHING EXTRACT
#}
#
module Reducers
  class FirstExtractReducer < Reducer
    def reduction_data_for(extractions, reduction)
      if running_reduction? && reduction&.data.present?
        reduction.data
      else
        extractions&.fetch(0, nil)&.data || {}
      end
    end
  end
end
