require 'spec_helper'

describe Reducers::StatsReducer do
  subject(:reducer) { described_class.new("s") }
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
      expect(reducer.process([])).to eq({})
    end

    it 'counts occurrences of species' do
      expect(reducer.process(extracts))
        .to include({"NTHNGHR" => 2, "RCCN" => 3, "BBN" => 1})
    end

    it 'counts occurrences inside a subrange' do
      reducer = described_class.new("s", {"filters" => {"from" => 0, "to" => 2}})
      expect(reducer.process(extracts)).to include({"NTHNGHR" => 1})
    end

    it 'counts booleans as 1' do
      extracts = [Extract.new(data: {'blank' => true}), Extract.new(data: {'blank' => false})]
      expect(reducer.process(extracts)).to eq('blank' => 1)
    end
  end
end
