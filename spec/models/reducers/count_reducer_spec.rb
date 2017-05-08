require 'spec_helper'

describe Reducers::CountReducer do
  let(:reducer) { described_class.new("s",{}) }

  it 'counts classifications' do
    expect(reducer.process([])).to include('classifications' => 0)
    expect(reducer.process([Extract.new(classification_id: 1), Extract.new(classification_id: 1),
                            Extract.new(classification_id: 2), Extract.new(classification_id: 2)])).to include('classifications' => 2)
  end

  it 'counts extracts' do
    expect(reducer.process([])).to include('extracts' => 0)
    expect(reducer.process([Extract.new, Extract.new, Extract.new, Extract.new])).to include('extracts' => 4)
  end
end
