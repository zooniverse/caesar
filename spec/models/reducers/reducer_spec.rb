require 'spec_helper'

describe Reducers::Reducer do

  let(:extracts) {
    [
      Extract.new(
        :classification_id => 1234,
        :classification_at => Date.new(2014,12,4),
        :data => { "foo" => "bar" }
      ),
      Extract.new(
        :classification_id => 1234,
        :classification_at => Date.new(2014,12,4),
        :data => { "foo" => "baz" }
      ),
      Extract.new(
        :classification_id => 1235,
        :classification_at => Date.new(1980,10,22),
        :data => { "bar" => "baz" }
      ),
      Extract.new(
        :classification_id => 1236,
        :classification_at => Date.new(2017,2,7),
        :data => { "baz" => "bar" }
      ),
      Extract.new(
        :classification_id => 1237,
        :classification_at => Date.new(2017,2,7),
        :data => { "foo" => "fufufu" }
      )
    ]
  }

  subject(:reducer) {
    described_class.new(
      "s",
      {
        "subranges" =>
          [
            {:from => 0, :to => 1},
            {:from => 3, :to => 3}
          ]
      }
    )
  }

  describe 'extract grouping' do

    let(:groups){ reducer.group_extracts(extracts) }

    it 'produces a group for each classification' do
      correct_size = extracts.map(&:classification_id).uniq.size

      expect(groups.size).to eq(correct_size)
      expect(groups[0]).to have_key(:classification_id)
    end

    it 'groups extracts by their classification id' do
      expect(groups).to include({
        :classification_id => 1234,
        :data => [
          extracts[0],
          extracts[1]
        ]
        })
      expect(groups).to include({
        :classification_id => 1235,
        :data => [ extracts[2] ]
      })
    end

    it 'orders extract groups by classification_at' do
      expect(groups[0][:classification_id]).to eq(1235)
      expect(groups[1][:classification_id]).to eq(1234)
    end

  end

  describe 'subrange slicing' do

    it 'returns only requested elements' do
      result = reducer.apply_subranges([0, 1, 2, 3, 4, 5])
      expect(result.size).to eq(3)
      expect(result[-1]).to eq(3)
    end

  end

  describe 'extract filtering' do
    let(:filtered){ reducer.filter_extracts(extracts) }

    it 'gives the right number of extracts' do
      expect(filtered.size).to eq(4)
    end

    it 'has all the relevant extracts' do
      expect(filtered).to include(extracts[0])
      expect(filtered).to include(extracts[1])
      expect(filtered).to include(extracts[2])
      expect(filtered).to include(extracts[4])
    end

  end

end
