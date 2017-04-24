require 'spec_helper'

describe Conditions::All do
  let(:sample){
    described_class.new(
      'friends',
      Conditions::Comparison.new(
        'lt', [
          Conditions::Lookup.new('value'),
          Conditions::Constant.new(2)
        ]
      )
    )
  }

  it('throws an error on empty bindings') do
    expect {
      sample.apply(nil)
    }.to raise_error(NoMethodError)
  end

  it('throws an error on bindings that lack the requested dictionary') do
    expect {
      sample.apply({ 'blah' => {} })
    }.to raise_error(KeyError)
  end

  it('is true when there are less than 2 of every critter') do
    result = sample.apply({ 'friends' => {:serval =>1, :kaban => 1, :ibis => 1} })
    expect(result).to be(true)
  end

  it('is false when there are more than 2 of a critter') do
    result = sample.apply({ 'friends' => {:serval =>1, :kaban => 1, :cerulean => 5} })
    expect(result).to be(false)
  end
end
