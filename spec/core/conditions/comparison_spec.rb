require 'spec_helper'

describe Conditions::Comparison do
  describe 'lt' do
    it 'returns true if all the operations are monotonically increasing in value' do
      comparison = described_class.new(:lt, [constant(1), constant(2), constant(4)])
      expect(comparison.apply({})).to be_truthy
    end

    it 'returns false if some value is the same' do
      comparison = described_class.new(:lt, [constant(1), constant(1), constant(4)])
      expect(comparison.apply({})).to be_falsey
    end

    it 'returns false if some value is lower' do
      comparison = described_class.new(:lt, [constant(1), constant(2), constant(1)])
      expect(comparison.apply({})).to be_falsey
    end
  end

  describe 'lte' do
    it 'returns true if all the operations are increasing in value' do
      comparison = described_class.new(:lte, [constant(1), constant(1), constant(2), constant(4)])
      expect(comparison.apply({})).to be_truthy
    end

    it 'returns false if some value is lower' do
      comparison = described_class.new(:lte, [constant(1), constant(2), constant(1)])
      expect(comparison.apply({})).to be_falsey
    end
  end

  describe 'gt' do
    it 'returns true if all the operations are monotonically decreasing in value' do
      comparison = described_class.new(:gt, [constant(4), constant(2), constant(1)])
      expect(comparison.apply({})).to be_truthy
    end

    it 'returns false if some value is the same' do
      comparison = described_class.new(:gt, [constant(4), constant(2), constant(2)])
      expect(comparison.apply({})).to be_falsey
    end

    it 'returns false if some value is higher' do
      comparison = described_class.new(:gt, [constant(4), constant(2), constant(4)])
      expect(comparison.apply({})).to be_falsey
    end
  end

  describe 'gte' do
    it 'returns true if all the operations are decreasing in value' do
      comparison = described_class.new(:gte, [constant(4), constant(2), constant(2), constant(1)])
      expect(comparison.apply({})).to be_truthy
    end

    it 'returns false if some value is higher' do
      comparison = described_class.new(:gte, [constant(4), constant(2), constant(4)])
      expect(comparison.apply({})).to be_falsey
    end
  end

  describe 'eq' do
    it 'returns true if all the operations are equal in value' do
      comparison = described_class.new(:eq, [constant(4), constant(4), constant(4), constant(4)])
      expect(comparison.apply({})).to be_truthy
    end

    it 'returns false if one value is different' do
      comparison = described_class.new(:eq, [constant(4), constant(2), constant(4)])
      expect(comparison.apply({})).to be_falsey
    end

  end

  def constant(value)
    Conditions::Constant.new(value)
  end
end
