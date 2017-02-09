require 'spec_helper'

describe Reducers::SimpleCountReducer do
  let(:reducer) { described_class.new("s",{}) }

  it 'counts things' do
    expect(reducer.process([])).to eq(0)
    expect(reducer.process([Extract.new, Extract.new, Extract.new, Extract.new])).to eq(4)
  end
end
