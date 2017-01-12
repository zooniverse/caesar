require 'spec_helper'

describe Conditions::Lookup do
  it 'returns the stored value' do
    expected = double
    expect(described_class.new("a").apply("a" => expected)).to eq(expected)
  end
end
