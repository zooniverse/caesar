require 'spec_helper'

describe Conditions::Calculator do
  let(:bindings) { double("RuleBindings") }
  let(:operations) { [const(1), const(5), const(-3)] }

  describe '+' do
    it 'adds arguments' do
      condition = described_class.new('+', operations)
      expect(condition.apply(bindings)).to eq(3)
    end
  end

  describe '-' do
    it 'subtracts arguments' do
      condition = described_class.new('-', operations)
      expect(condition.apply(bindings)).to eq(-1)
    end
  end

  describe '*' do
    it 'multiplies arguments' do
      condition = described_class.new('*', operations)
      expect(condition.apply(bindings)).to eq(-15)
    end
  end

  describe '/' do
    it 'divides arguments' do
      condition = described_class.new('/', [const(5), const(2)])
      expect(condition.apply(bindings)).to eq(2.5)
    end
  end

  describe '%' do
    it 'takes the remainder' do
      condition = described_class.new('%', [const(5), const(2)])
      expect(condition.apply(bindings)).to eq(1)
    end
  end

  def const(val)
    Conditions::Constant.new(val)
  end
end
