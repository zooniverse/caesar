require 'spec_helper'

describe Reducers::CountChoicesReducer do
  subject(:reducer) { described_class.new("s") }
  let(:extracts){
    [
      Extract.new(
        :classification_id => 1234,
        :classification_at => Date.new(2017,2,5),
        :data => { "value" => "0"}
      ),
      Extract.new(
        :classification_id => 1234,
        :classification_at => Date.new(2017,2,5),
        :data => { "value" => "0"}
      ),
      Extract.new(
        :classification_id => 1234,
        :classification_at => Date.new(2017,2,5),
        :data => { "value" => "0"}
      ),
      Extract.new(
        :classification_id => 1234,
        :classification_at => Date.new(2017,2,5),
        :data => { "value" => "1"}
      ),
      Extract.new(
        :classification_id => 1234,
        :classification_at => Date.new(2017,2,5),
        :data => { "value" => "0"}
      )
    ]
  }

  describe '#process' do
    it 'processes when there are no classifications' do
      expect(reducer.process([])).to eq({})
    end
    it 'groups and counts the extractions' do
      expect(reducer.process(extracts)).to eq( "0"=>4, "1"=>1 )
    end
  end

end
