require 'spec_helper'

describe ExtractFilter do

  let(:extracts) {
    [
      Extract.new(
        id: 0,
        :classification_id => 1234,
        :classification_at => Date.new(2014,12,4),
        :data => {"foo" => "bar"}
      ),
      Extract.new(
        id: 1,
        :classification_id => 1234,
        :classification_at => Date.new(2014,12,4),
        :data => {"foo" => "baz"}
      ),
      Extract.new(
        id: 2,
        :classification_id => 1235,
        :classification_at => Date.new(1980,10,22),
        :data => {"bar" => "baz"}
      ),
      Extract.new(
        id: 3,
        :classification_id => 1236,
        :classification_at => Date.new(2017,2,7),
        :data => {"baz" => "bar"}
      ),
      Extract.new(
        id: 4,
        :classification_id => 1237,
        :classification_at => Date.new(2017,2,7),
        :data => {"foo" => "fufufu"}
      )
    ]
  }

  describe 'with no filters' do
    let(:filter) { ExtractFilter.new(extracts, {}) }

    it 'returns the unfiltered list of extracts, sorted by classification_at' do
      expect(filter.to_a).to eq([extracts[2], extracts[0], extracts[1], extracts[3], extracts[4]])
    end
  end

  describe 'subrange filtering' do
    it 'returns extracts starting from a given index' do
      filter = described_class.new(extracts, from: 2)
      expect(filter.to_a).to eq([extracts[3], extracts[4]])
    end

    it 'returns extracts up to a given index' do
      filter = described_class.new(extracts, to: 1)
      expect(filter.to_a).to eq([extracts[2], extracts[0], extracts[1]])
    end

    it 'returns extracts except the last N' do
      filter = described_class.new(extracts, to: -2)
      expect(filter.to_a).to eq([extracts[2], extracts[0], extracts[1], extracts[3]])
    end

    it 'returns extracts in a slice' do
      filter = described_class.new(extracts, from: 1, to: 2)
      expect(filter.to_a).to eq([extracts[0], extracts[1], extracts[3]])
    end
  end
end
