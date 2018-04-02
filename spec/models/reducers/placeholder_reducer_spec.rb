require 'spec_helper'

describe Reducers::PlaceholderReducer do
  describe '#reduce_into' do
    it 'does nothing' do
      reducer = described_class.new

      expect(reducer.reduce_into(nil, create(:subject_reduction)).data).to be(nil)
      expect(reducer.reduce_into([], create(:subject_reduction)).data).to be(nil)
      expect(reducer.reduce_into([Extractor::NoData], create(:subject_reduction)).data).to be(nil)
      expect(reducer.reduce_into([build(:extract)], create(:subject_reduction)).data).to be(nil)
      expect(reducer.reduce_into([build(:extract), build(:extract)], create(:subject_reduction)).data).to be(nil)
    end
  end

end
