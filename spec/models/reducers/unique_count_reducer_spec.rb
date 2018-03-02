require 'spec_helper'

describe Reducers::UniqueCountReducer do
  def unwrap(reduction)
    reduction[0][:data]
  end

  let(:reducer) { described_class.new(config: {"field" => "choices"}) }
  let(:extracts) {
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
        :classification_id => 1237,
        :classification_at => Date.new(2017,2,7),
        :data => { "choices" => ["NTHNGHR"] }
      )
    ]
  }

  describe 'validations' do
    it 'is not valid without field' do
      reducer = described_class.new
      expect(reducer).not_to be_valid
      expect(reducer.errors[:field]).to be_present
    end
  end

  it 'counts unique things' do
    expect(unwrap(reducer.process(extracts))).to eq(2)
  end
end
