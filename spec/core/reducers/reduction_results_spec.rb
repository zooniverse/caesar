require 'spec_helper'

describe Reducers::ReductionResults do
  subject(:results) { described_class.new }

  it 'is empty initially' do
    expect(results.to_h).to be_empty
  end

  describe '.build' do
    it 'returns a hash with the values' do
      expect(described_class.build { |results| results.increment("a") }).to eq({"a" => 1})
    end
  end

  describe '#increment' do
    it 'creates a new key' do
      results.increment("a")
      results.increment("b")
      expect(results.to_h).to eq({"a" => 1, "b" => 1})
    end

    it 'increments multiple times' do
      5.times { results.increment("a") }
      3.times { results.increment("b") }
      expect(results.to_h).to eq({"a" => 5, "b" => 3})
    end
  end
end
