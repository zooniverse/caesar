module Reducers
  class ConsensusReducer < Reducer
    def reduction_data_for(extractions, reduction)
      store_value = reduction&.store || {}
      counter = CountingHash.new(store_value)

      extractions.each do |extraction|
        counter.increment(extraction.data.keys.sort.join("+"))
      end

      reduction.store = counter.to_h if reduction.present?
      most_likely, num_votes = counter.max

      if num_votes > 0
        agreement = num_votes.to_f / counter.sum

        {
          "most_likely" => most_likely,
          "num_votes" => num_votes,
          "agreement" => agreement
        }
      else
        {
          "num_votes" => num_votes
        }
      end
    end
  end
end
