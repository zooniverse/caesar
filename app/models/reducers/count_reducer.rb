# Reducers::CountReducer
#
# data: {
#  extracts: INT,
#  classifications: INT
# }
#
module Reducers
  class CountReducer < Reducer
    def reduction_data_for(extracts, reduction)
      data = reduction&.data || {}

      classifications_count = data.fetch("classifications", 0)
      extracts_count = data.fetch("extracts",0)

      {
        'classifications' => extracts.map(&:classification_id).uniq.size + classifications_count,
        'extracts' => extracts.size + extracts_count
      }
    end

  end
end
