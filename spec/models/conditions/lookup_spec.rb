require 'spec_helper'

describe Conditions::Lookup do
  it 'returns the stored value' do
    expected = double
    expect(described_class.new("a").apply("a" => expected)).to eq(expected)
  end

  it 'returns nil if the stored value is not present' do
    expected = double
    expect(described_class.new("b").apply("a" => expected)).to be(nil)
  end

  it 'returns default if the stored value is not present' do
    expected = double
    unexpected = double
    expect(described_class.new("b",unexpected).apply("a" => expected)).to eq(unexpected)
  end
end
