require 'spec_helper'

describe Conditions::TextTransform do
  it 'transforms strings to upper case' do
    condition = described_class.new(:upcase, constant("foo"))
    expect(condition.apply({})).to eq("FOO")
  end

  it 'transforms strings to lower case' do
    condition = described_class.new(:downcase, constant("fOo"))
    expect(condition.apply({})).to eq("foo")
  end

  it 'errors if argument is not a string' do
    condition = described_class.new(:upcase, constant(1))
    expect { condition.apply({}) }.to raise_error(TypeError)
  end

  def constant(value)
    Conditions::Constant.new(value)
  end
end
