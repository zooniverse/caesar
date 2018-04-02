# Reducers::CountReducer
#
# data: {
#  extracts: INT,
#  classifications: INT
# }
#
module Reducers
  class CountReducer < Reducer
    def reduce_into(extracts, reduction)
      data = reduction.data || {}

      classifications_count = data.fetch("classifications", 0)
      extracts_count = data.fetch("extracts",0)

      reduction.tap do |r|
        r.data = {
          'classifications' => extracts.map(&:classification_id).uniq.size + classifications_count,
          'extracts' => extracts.size + extracts_count
        }
      end
    end

  end
end
