require 'rails_helper'

RSpec.describe Reducer, type: :model do
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
        :classification_id => 1236,
        :classification_at => Date.new(2017,2,7),
        :data => { "baz" => "bar" }
      ),
      Extract.new(
        :classification_id => 1235,
        :classification_at => Date.new(1980,10,22),
        :data => { "bar" => "baz" }
      ),
      Extract.new(
        :classification_id => 1237,
        :classification_at => Date.new(2017,2,7),
        :data => { "foo" => "fufufu" }
      )
    ]
  }

  subject(:reducer) do
    klass = Class.new(described_class) do
      def reduction_data_for(extracts)
        extracts
      end
    end

    klass.new
  end

  it 'filters extracts' do
    extract_filter = instance_double(ExtractFilter, filter: [])
    expect(ExtractFilter).to receive(:new).with({}).and_return(extract_filter)
    subject.process(extracts)

    expect(extract_filter).to have_received(:filter).once
  end

  it 'groups extracts' do
    instance_double(ExtractFilter, filter: extracts)
    grouping_filter = instance_double(ExtractGrouping, to_h: {})
    expect(ExtractGrouping).to receive(:new).
      with(extracts, nil).
      and_return(grouping_filter)

    subject.process(extracts)

    expect(grouping_filter).to have_received(:to_h).once
  end

  it 'does not attempt reduction on repeated failures' do
    reducer= build :reducer
    allow(reducer).to receive(:reduction_data_for) { raise 'failure' }

    expect { reducer.process(extracts) }.to raise_error('failure')
    expect { reducer.process(extracts) }.to raise_error('failure')
    expect { reducer.process(extracts) }.to raise_error('failure')

    expect(reducer).not_to receive(:reduction_data_for)
    expect { reducer.process(extracts) }.to raise_error(Stoplight::Error::RedLight)
  end

  it 'composes grouping and filtering correctly' do
    fancy_extracts = [
      build(:extract, extractor_key: 'votes', classification_id: 1, subject_id: 1234, user_id: 5680, data: {"T0" => "ARAI"}),
      build(:extract, extractor_key: 'votes', classification_id: 2, subject_id: 1234, user_id: 5681, data: {"T0" => "ARAI"}),
      build(:extract, extractor_key: 'votes', classification_id: 3, subject_id: 1234, user_id: 5678, data: {"T0" => "ARAI"}),
      build(:extract, extractor_key: 'votes', classification_id: 4, subject_id: 1234, user_id: 5679, data: {"T0" => "ARAI"}),

      build(:extract, extractor_key: 'user_group', classification_id: 1, subject_id: 1234, user_id: 5680, data: {"id"=>"33"}),
      build(:extract, extractor_key: 'user_group', classification_id: 2, subject_id: 1234, user_id: 5681, data: {"id"=>"34"}),
      build(:extract, extractor_key: 'user_group', classification_id: 3, subject_id: 1234, user_id: 5678, data: {"id"=>"33"}),
      build(:extract, extractor_key: 'user_group', classification_id: 4, subject_id: 1234, user_id: 5679, data: {"id"=>"33"}),
    ]

    reducer = build :reducer, key: 'r', grouping: "user_group.id", filters: {"extractor_keys" => ["votes"]}
    allow(reducer).to receive(:reduction_data_for){ |reduce_me| reduce_me.map(&:data) }
    reductions = reducer.process(fancy_extracts)

    expect(reductions).to include("33", "34")
    expect(reductions['33'].count).to eq(3)
    expect(reductions['34'].count).to eq(1)
  end

  describe 'validations' do
    it 'is not valid with invalid filters' do
      reducer = Reducer.new filters: {repeated_classifications: "something"}
      expect(reducer).not_to be_valid
      expect(reducer.errors[:extract_filter]).to be_present
    end
  end
end
