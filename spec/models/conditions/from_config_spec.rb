# coding: utf-8
require 'spec_helper'

describe Conditions::FromConfig do
  # Since it's hard to test a DSLish domain object builder like the described class
  # without tightly coupling to the specifics that it generates (which seems silly),
  # these tests are written more as integration tests, checking that the entire stack
  # from build() through apply() and getting the result back works as expected.

  it 'builds a constant value' do
    condition = described_class.build([:const, 123])
    expect(condition.apply({})).to eq(123)
  end

  describe 'lookups' do
    it 'builds a comparison with a lookup' do
      condition = described_class.build([:lt, [:const, 1], [:lookup, "num", 0], [:const, 3]])
      expect(condition.apply({"num" => 2})).to eq(true)
      expect(condition.apply({"num" => 4})).to eq(false)
    end
  end

  it 'builds boolean algebra' do
    condition = described_class.build([:and,
      [:or, [:const, false],
            [:not, [:const, false]]],
      [:and, [:const, true],
             [:const, true]]])

    expect(condition.apply({})).to eq(true)
  end

  it 'builds an any loop' do
    condition = described_class.build([
      :any,
      'desert',
      [
        :gte,
        [:lookup, 'value', 0],
        [:const, 2]
      ]
    ])

    binding = RuleBindings.new(
      [
        Reduction.new(reducer_id: 'desert', data: {:snek => 1, :sand_cat => 1})
      ]
    )

    expect(condition.apply(binding)).to be(false)
  end

end
