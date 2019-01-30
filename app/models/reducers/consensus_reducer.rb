module Reducers
  class ConsensusReducer < Reducer
    config_field :ignore_empty_extracts, default: false

    def reduce_into(extractions, reduction, _relevant_reductions=[])
      store_value = reduction.store || {}
      counter = CountingHash.new(store_value)

      extractions.each do |extraction|
        next if ignore_empty_extracts && extraction.data.blank?
        counter.increment(extraction.data.keys.sort.join("+"))
      end

      most_likely, num_votes = counter.max

      reduction.tap do |r|
        r.store = counter.to_h
        r.data = if num_votes > 0
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
end
