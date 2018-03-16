module Reducers
  class UniqueCountReducer < Reducer
    config_field :field

    def reduction_data_for(extracts, reduction)
      store = reduction&.store || {}
      store["items"] = [] unless store.key? "items"

      mapped = (store["items"] + extracts.map do |extract|
        if extract.data.key?(field)
          val = extract.data[field]
          if val.respond_to?('sort') && val.respond_to?('join') then val.sort.join('+') else val end
        end
      end).uniq

      reduction.store["items"] = mapped if reduction.present?

      mapped.size
    end
  end
end
