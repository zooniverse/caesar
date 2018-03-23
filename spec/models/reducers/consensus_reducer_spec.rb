require 'spec_helper'

describe Reducers::ConsensusReducer do
  subject(:reducer) { described_class.new }

  def build_extracts(choices)
    choices.map.with_index do |choice, idx|
      vals = Array.wrap(choice)
      data = vals.map { |val| {val => 1} }.reduce(:merge) || {}

      Extract.new(
        classification_id: idx,
        classification_at: Date.new(2017, 2, 6),
        data: data
      )
    end
  end

  describe '#process' do
    it 'processes when there are no classifications' do
      expect(reducer.reduction_data_for([],nil)).to include({"num_votes" => 0})
    end

    it 'returns the most likely' do
      extracts = build_extracts(["ZEBRA", "ZEBRA", "ZEBRA", ["ZEBRA", "BIRD"]])
      expect(reducer.reduction_data_for(extracts, nil))
        .to include({"most_likely" => "ZEBRA", "agreement" => 0.75, "num_votes" => 3})
    end

    it 'handles multiple species' do
      extracts = build_extracts([["ZEBRA", "BIRD"], ["BIRD", "ZEBRA"]])
      expect(reducer.reduction_data_for(extracts,nil))
        .to include({"most_likely" => "BIRD+ZEBRA", "agreement" => 1.0, "num_votes" => 2})
    end
  end

  describe 'aggregation modes' do
    it 'works in default aggregation mode' do
      default_reducer = described_class.new(reduction_mode: Reducer.reduction_modes[:default_reduction])

      reduction = create :subject_reduction
      result = default_reducer.reduction_data_for(build_extracts(["ZEBRA", "ZEBRA", "ZEBRA"]), reduction)
      expect(result).to include({"most_likely" => "ZEBRA"})
      expect(result).to include({"num_votes" => 3})

      reduction = create :subject_reduction
      result = default_reducer.reduction_data_for(build_extracts(["ZEBRA", "ZEBRA"]), reduction)
      expect(result).to include({"most_likely" => "ZEBRA"})
      expect(result).to include({"num_votes" => 2})
    end

    it 'works in running aggregation mode' do
      running_reducer = described_class.new(reduction_mode: Reducer.reduction_modes[:running_reduction])

      reduction = create :subject_reduction, store: {"RCCN" => 4}
      result = running_reducer.reduction_data_for(build_extracts(["ZEBRA", "ZEBRA", "ZEBRA"]), reduction)
      expect(result).to include({"most_likely" => "RCCN"})
      expect(result).to include({"num_votes" => 4})

      result = running_reducer.reduction_data_for(build_extracts(["ZEBRA", "ZEBRA"]), reduction)
      expect(result).to include({"most_likely" => "ZEBRA"})
      expect(result).to include({"num_votes" => 5})
    end
  end

end
