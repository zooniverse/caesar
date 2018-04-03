require 'spec_helper'

describe Reducers::StatsReducer do
  subject(:reducer) { described_class.new }
  let(:extracts){
    [
      Extract.new(
        :classification_id => 1234,
        :classification_at => Date.new(2017,2,5),
        :data => {"NTHNGHR" => 1}
      ),
      Extract.new(
        :classification_id => 1235,
        :classification_at => Date.new(2017,2,5),
        :data => {"RCCN" => 2}
      ),
      Extract.new(
        :classification_id => 1236,
        :classification_at => Date.new(2017,2,6),
        :data => {"RCCN" => 1, "BBN" => 1}
      ),
      Extract.new(
        :classification_id => 1237,
        :classification_at => Date.new(2017,2,7),
        :data => {"NTHNGHR" => 1}
      )
    ]
  }

  describe '#process' do
    it 'processes when there are no classifications' do
      expect(reducer.reduce_into([], build(:subject_reduction)).data).to eq({})
    end

    it 'counts occurrences of species' do
      # expect(unwrap(reducer.process(extracts)))
      expect(reducer.reduce_into(extracts, build(:subject_reduction)).data)
        .to include({"NTHNGHR" => 2, "RCCN" => 3, "BBN" => 1})
    end

    it 'counts booleans as 1' do
      extracts = [Extract.new(data: {'blank' => false})]
      expect(reducer.reduce_into(extracts, build(:subject_reduction)).data).to eq('blank' => 0)

      extracts = [Extract.new(data: {'blank' => true}), Extract.new(data: {'blank' => false})]
      expect(reducer.reduce_into(extracts, build(:subject_reduction)).data).to eq('blank' => 1)
    end

    it 'works in default aggregation mode' do
      running_reducer = described_class.new(reduction_mode: Reducer.reduction_modes[:default_reduction])
      reduction = build :subject_reduction

      result = running_reducer.reduce_into(extracts, reduction)
      expect(result.data).to include({"NTHNGHR" => 2})
      expect(result.data).to include({"RCCN" => 3})
    end

    it 'works in running aggregation mode' do
      running_reducer = described_class.new(reduction_mode: Reducer.reduction_modes[:running_reduction])
      reduction = build :subject_reduction, data: {"NTHNGHR" => 1, "RCCN" => 2}

      result = running_reducer.reduce_into(extracts, reduction)
      expect(result.data).to include({"NTHNGHR" => 3})
      expect(result.data).to include({"RCCN" => 5})
    end
  end
end
