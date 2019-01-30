module Reducers
  class UniqueCountReducer < Reducer
    config_field :field

    def reduce_into(extracts, reduction, _relevant_reductions=[])
      store = reduction.store || {}
      store["items"] = [] unless store.key? "items"

      mapped = (store["items"] + extracts.map do |extract|
        if extract.data.key?(field)
          val = extract.data[field]
          if val.respond_to?('sort') && val.respond_to?('join') then val.sort.join('+') else val end
        end
      end).uniq

      reduction.tap do |r|
        r.store = store
        r.store["items"] = mapped
        r.data = mapped.size
      end
    end
  end
end
