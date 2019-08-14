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

  it 'if absent_val is a string, absent_val_display() should wrap the value in single quotes' do
    expect(described_class.new("a", "5").absent_val_display()).to eq("'5'")
  end

  it 'if absent_val is not a string, absent_val_display() should not wrap the value in single quotes' do
    expect(described_class.new("a", 5).absent_val_display()).to eq(5)
  end
end
