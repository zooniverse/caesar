require 'spec_helper'

describe Reducers::UniqueCountReducer do
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
        :data => { "choices" => ["RCCN", "BR"]}
      ),
      Extract.new(
        :classification_id => 1237,
        :classification_at => Date.new(2017,2,7),
        :data => { "choices" => ["BR", "RCCN"] }
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
    expect(reducer.reduction_data_for(extracts, nil)).to eq(2)
  end

  describe 'aggregation modes' do
    it 'works correctly in default aggregation mode' do
      default_reducer = described_class.new(reduction_mode: Reducer.reduction_modes[:default_reduction], config: {"field" => "choices"})

      extracts = [create(:extract, data: {"choices"=>"B"}), create(:extract, data: {"choices"=>"C"})]
      reduction = create :subject_reduction, store: {}

      expect(default_reducer.reduction_data_for(extracts, reduction)).to eq(2)

      reduction.store = {}
      expect(default_reducer.reduction_data_for([extracts[0]], reduction)).to eq(1)
    end

    it 'works correctly in running aggregation mode' do
      running_reducer = described_class.new(reduction_mode: Reducer.reduction_modes[:running_reduction], config: {"field" => "choices"})

      extracts = [create(:extract, data: {"choices"=>"B"}), create(:extract, data: {"choices"=>"C"})]
      reduction = create :subject_reduction, store: { "items" => ["A", "B"] }

      expect(running_reducer.reduction_data_for(extracts, reduction)).to eq(3)
      expect(running_reducer.reduction_data_for([extracts[0]], reduction)).to eq(3)
    end
  end
end
