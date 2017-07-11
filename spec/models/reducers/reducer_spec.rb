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

    klass.new("s")
  end

  it 'filters extracts' do
    extract_filter = instance_double(ExtractFilter, to_a: [])
    expect(ExtractFilter).to receive(:new).with(extracts, {}).and_return(extract_filter)
    subject.process(extracts)

    expect(extract_filter).to have_received(:to_a).once
  end

  it 'groups extracts' do
    instance_double(ExtractFilter, to_a: extracts)
    grouping_filter = instance_double(ExtractGrouping, to_h: {})
    expect(ExtractGrouping).to receive(:new).
      with(extracts.sort_by{ |e| e.classification_at }, nil).
      and_return(grouping_filter)

    subject.process(extracts)

    expect(grouping_filter).to have_received(:to_h).once
  end
end
