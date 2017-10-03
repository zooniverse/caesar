module Reducers
  class UniqueCountReducer < Reducer
    config_field :field

    def reduction_data_for(extracts)
      mapped = extracts.map do |extract|
        if extract.data.key?(field)
          extract.data[field]
        end
      end

      mapped.uniq.size
    end
  end
end
