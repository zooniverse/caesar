require 'spec_helper'

describe ExtractGrouping do
  let(:extracts){
    [
      Extract.new(
        :classification_id => 1237,
        :classification_at => Date.new(2017,2,7),
        :data => { "foo" => "fufufu" }
      ),
      Extract.new(
        :classification_id => 1234,
        :classification_at => Date.new(2014,12,4),
        :data => { "foo" => "bar" }
      ),
      Extract.new(
        :classification_id => 1234,
        :classification_at => Date.new(2014,12,4),
        :data => { "foo" => "bar" }
      ),
      Extract.new(
        :classification_id => 1236,
        :classification_at => Date.new(2017,2,7),
        :data => { "foo" => "baz" }
      ),
      Extract.new(
        :classification_id => 1235,
        :classification_at => Date.new(1980,10,22),
        :data => { "foo" => "baz" }
      )
    ]
  }

  let(:nogroup){
    ExtractGrouping.new(extracts, nil)
  }

  let(:grouping){
    ExtractGrouping.new(extracts, "foo")
  }

  let(:missing){
    ExtractGrouping.new(extracts,"bar")
  }

  describe '#initialize' do
    it('constructs the grouping object') do
      expect(grouping.extracts).to eq(extracts)
      expect(grouping.subgroup).to eq("foo")
    end
  end

  describe '#to_h' do
    it('works when no grouping is defined') do
      grouped = nogroup.to_h
      expect(grouped).to have_key("_default")
      expect(grouped["_default"]).to eq(extracts)
    end

    it('throws an error if an extract is missing the key') do
      expect { missing.to_h }.to raise_error(MissingGroupingField)
    end

    it('groups extracts correctly') do
      grouped = grouping.to_h
      expect(grouped.keys.sort()).to eq(["bar", "baz", "fufufu"])
      expect(grouped["fufufu"]).to include(extracts[0])
      expect(grouped["fufufu"]).not_to include(extracts[1])

      expect(grouped["bar"]).not_to include(extracts[0])
      expect(grouped["bar"]).to include(extracts[1])
      expect(grouped["bar"]).to include(extracts[2])
    end
  end

end
