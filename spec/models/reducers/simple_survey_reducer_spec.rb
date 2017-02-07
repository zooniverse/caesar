require 'spec_helper'

describe Reducers::SimpleSurveyReducer do
  subject(:reducer) { described_class.new("s") }
  let(:extracts){
    [
      Extract.new(
        :classification_id => 1234,
        :classification_at => Date.new(2017,2,5),
        :data => { "choices" => ["NTHNGHR"] }
      ),
      Extract.new(
        :classification_id => 1235,
        :classification_at => Date.new(2017,2,5),
        :data => { "choices" => ["RCCN", "RCCN"]}
      ),
      Extract.new(
        :classification_id => 1236,
        :classification_at => Date.new(2017,2,6),
        :data => { "choices" => ["RCCN", "BBN"]}
      ),
      Extract.new(
        :classification_id => 1237,
        :classification_at => Date.new(2017,2,7),
        :data => { "choices" => ["NTHNGHR"] }
      )
    ]
  }

  describe '#process' do
    it 'processes when there are no classifications' do
      expect(reducer.process([])).to eq({})
    end

    it 'counts occurrences of species' do
      expect(reducer.process(extracts))
        .to include({"survey-total-NTHNGHR" => 2, "survey-total-RCCN" => 3, "survey-total-BBN" => 1})
    end

    it 'counts occurrences of species within the first 3 classifications' do
      expect(reducer.process(extracts)).to include({"survey-filtered-NTHNGHR" => 1})
    end
  end
end
