require 'spec_helper'

describe Reducers::UniqueCountReducer do
  let(:reducer){ described_class.new("s",{})}

  it 'counts things' do
    expect(reducer.process([])).to eq(0)
    expect(reducer.process([3, 4, 5, 6])).to eq(4)
    expect(reducer.process([{"user_id"=>3},{"user_id"=>4}])).to eq(2)
  end

  it 'counts unique things' do
    expect(reducer.process([3,4,3,6])).to eq(3)
    expect(reducer.process([{"user_id"=>3},{"user_id"=>4},{"user_id"=>3}])).to eq(2)
  end
end
