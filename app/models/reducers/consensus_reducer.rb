module Reducers
  class ConsensusReducer < Reducer
    def reduction_data_for(extractions)
      counter = CountingHash.new

      extractions.each do |extraction|
        counter.increment(extraction.data.keys)
      end

      most_likely, num_votes = counter.max

      if num_votes > 0
        agreement = num_votes.to_f / counter.sum

        {
          "most_likely" => most_likely.sort.join("+"),
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
