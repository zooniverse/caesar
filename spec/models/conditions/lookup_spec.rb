require 'spec_helper'

describe Conditions::Lookup do
  it 'returns the stored value' do
    expected = double
    expect(described_class.new("a", 0).apply("a" => expected)).to eq(expected)
  end

  it 'returns default if the stored value is not present' do
    expected = double
    default = double
    expect(described_class.new("b", default).apply("a" => expected)).to eq(default)
  end
end
