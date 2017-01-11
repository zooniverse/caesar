require 'spec_helper'

describe Rules::Constant do
  let(:bindings) { double }

  it 'returns the stored value' do
    expected = double
    expect(described_class.new(expected).apply(bindings)).to eq(expected)
  end
end
