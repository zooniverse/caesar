require 'spec_helper'

describe Reducers::UniqueCountReducer do
  def unwrap(reduction)
    reduction['_default']
  end

  let(:reducer){ described_class.new("s",{"field" => "choices"})}
  let(:extracts){
    [
      Extract.new(
        :classification_id => 1234,
        :classification_at => Date.new(2017,2,5),
        :data => { "choices" => ["NTHNGHR"] }
      ),
      Extract.new(
        :classification_id => 1235,
        :classification_at => Date.new(2017,2,5),
        :data => { "choices" => ["RCCN", "RCCN"]}
      ),
      Extract.new(
        :classification_id => 1237,
        :classification_at => Date.new(2017,2,7),
        :data => { "choices" => ["NTHNGHR"] }
      )
    ]
  }

  it 'counts unique things' do
    expect(unwrap(reducer.process(extracts))).to eq(2)
  end
end
