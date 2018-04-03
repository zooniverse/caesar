require 'spec_helper'

describe Reducers::PlaceholderReducer do
  describe '#reduce_into' do
    it 'does nothing' do
      reducer = described_class.new

      expect(reducer.reduce_into(nil, build(:subject_reduction)).data).to be(nil)
      expect(reducer.reduce_into([], build(:subject_reduction)).data).to be(nil)
      expect(reducer.reduce_into([Extractor::NoData], build(:subject_reduction)).data).to be(nil)
      expect(reducer.reduce_into([build(:extract)], build(:subject_reduction)).data).to be(nil)
      expect(reducer.reduce_into([build(:extract), build(:extract)], build(:subject_reduction)).data).to be(nil)
    end
  end

end
