module Reducers
  class CountReducer < Reducer
    def reduction_data_for(extracts, reduction)
      {
        'classifications' => extracts.map(&:classification_id).uniq.size,
        'extracts' => extracts.size
      }
    end
  end
end
