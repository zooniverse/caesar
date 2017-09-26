require 'spec_helper'

describe Reducers::PlaceholderReducer do
  describe '#reduction_data_for' do
    it 'does nothing' do
      reducer = described_class.new

      expect(reducer.reduction_data_for(nil)).to eq(Reducer::NoData)
      expect(reducer.reduction_data_for([])).to eq(Reducer::NoData)
      expect(reducer.reduction_data_for([Extractor::NoData])).to eq(Reducer::NoData)
      expect(reducer.reduction_data_for([build(:extract)])).to eq(Reducer::NoData)
      expect(reducer.reduction_data_for([build(:extract), build(:extract)])).to eq(Reducer::NoData)
    end
  end

end
