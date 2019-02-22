# Reducers::FirstExtractReducer
#
# data: {
#   SHAPE OF FIRST MATCHING EXTRACT
#}
#
module Reducers
  class FirstExtractReducer < Reducer
    def reduce_into(extractions, reduction)
      reduction.tap do |r|
        r.data = if reduction.data.blank? then (extractions&.fetch(0, nil)&.data || {}) else reduction.data end
      end
    end
  end
end
