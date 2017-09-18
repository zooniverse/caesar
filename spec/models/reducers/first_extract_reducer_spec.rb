require 'spec_helper'

describe Reducers::FirstExtractReducer do

  def unwrap(reduction)
    reduction['_default']
  end

  let(:extracts) do
    [
      Extract.new(data: {"foo" => "bar", "bar" => "baz"}),
      Extract.new(data: {"foo" => "bar", "bar" => "bar"})
    ]

  end

  describe '#process' do
    it 'handles an empty extract list' do
      reducer = described_class.new
      result = reducer.process([])

      expect(unwrap(result)).to eq({})
    end

    it 'returns whatever is in the first extract no matter what' do
      reducer = described_class.new

      result = reducer.process(extracts)
      expect(unwrap(result)).to eq({"foo" => "bar", "bar" => "baz"})

      result = reducer.process([extracts[0]])
      expect(unwrap(result)).to eq({"foo" => "bar", "bar" => "baz"})
    end
  end
end
