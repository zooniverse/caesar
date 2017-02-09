module Reducers
  class UniqueCountReducer < Reducer
    def reduction_data_for(extracts)
      mapped = extracts.map do |extract|
        if extract.data.key?(unique_field)
          extract.data[unique_field]
        end
      end

      mapped.uniq.size
    end

    def unique_field
      config["field"]
    end
  end
end
