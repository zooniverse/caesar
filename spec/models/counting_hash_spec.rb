require 'spec_helper'

describe CountingHash do
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

  describe '#max' do
    it 'works for empty hash' do
      expect(results.max).to eq([nil, 0])
    end

    it 'returns the top result' do
      results.increment("a")
      expect(results.max).to eq(["a", 1])

      results.increment("b")
      results.increment("b")
      results.increment("b")
      results.increment("b")
      expect(results.max).to eq(["b", 4])
    end
  end

  describe '#sum' do
    it 'works for empty hash' do
      expect(results.sum).to eq(0)
    end

    it 'returns the sum of all the counts' do
      results.increment("a")
      results.increment("b")
      results.increment("b")
      results.increment("c")
      expect(results.sum).to eq(4)
    end
  end
end
