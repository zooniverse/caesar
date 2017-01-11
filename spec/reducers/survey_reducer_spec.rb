require 'spec_helper'

describe Reducers::SimpleSurveyReducer do
  subject(:reducer) { described_class.new }

  describe '#process' do
    it 'processes when there are no classifications' do
      expect(reducer.process([])).to eq({})
    end

    it 'counts occurrences of species' do
      expect(reducer.process([
        {"choices" => ["NTHNGHR"]},
        {"choices" => ["RCCN", "RCCN"]},
        {"choices" => ["RCCN", "BBN"]},
        {"choices" => ["NTHNGHR"]},
      ])).to include({"survey-total-NTHNGHR" => 2, "survey-total-RCCN" => 3, "survey-total-BBN" => 1})
    end

    it 'counts occurrences of species within the first 3 classifications' do
      expect(reducer.process([
        {"choices" => ["NTHNGHR"]},
        {"choices" => ["RCCN", "RCCN"]},
        {"choices" => ["RCCN", "BBN"]},
        {"choices" => ["NTHNGHR"]},
      ])).to include({"survey-from0to2-NTHNGHR" => 1})
    end
  end
end
