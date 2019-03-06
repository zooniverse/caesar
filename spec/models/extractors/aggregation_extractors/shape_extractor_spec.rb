require 'spec_helper'

describe Extractors::AggregationExtractors::ShapeExtractor do
  let(:subject){ create :subject }
  let(:workflow){ create :workflow }
  let(:classification) do
    Classification.new(
      "id" => "12329",
      "annotations" => [{"task" => "T0", "value" => "foo"}],
      "metadata" => {},
      "created_at" => "",
      "updated_at" => "",
      "links" => {"project" => "1232", "workflow" => workflow.id.to_s, "subjects" => [subject.id], "user" => nil}
    )
  end

  it 'accepts a valid shape' do
    extractor = described_class.new(
      key: 'ext',
      workflow: workflow,
      config: {
        shape: 'circle'
      }
    )

    expect(extractor).to be_valid
  end

  it 'rejects a bad shape' do
    extractor = described_class.new(
      key: 'ext',
      workflow: workflow,
      config: {
        shape: 'blah'
      }
    )

    expect(extractor).not_to be_valid
  end

  it 'require a shape' do
    extractor = described_class.new(
      key: 'ext',
      workflow: workflow,
      config: {
      }
    )

    expect(extractor).not_to be_valid
  end

  it 'builds the url correctly' do
    extractor = described_class.new(
      key: 'ext',
      workflow: workflow,
      config: {
        shape: 'circle'
      }
    )

    expect(extractor.url).to eq(
      'https://aggregation-caesar.zooniverse.org/extractors/shape_extractor?shape=circle&task_key=T0'
    )
  end

  it 'extracts correctly' do
    stub_request(:post, 'https://aggregation-caesar.zooniverse.org/extractors/shape_extractor?shape=circle&task_key=T0').
      to_return(status: 204, body: "", headers: {})

    extractor = described_class.new(
      key: 'ext',
      workflow: workflow,
      config: {
        shape: 'circle'
      }
    )

    result = extractor.process(classification)
    expect(a_request(:post, 'https://aggregation-caesar.zooniverse.org/extractors/shape_extractor?shape=circle&task_key=T0'))
      .to have_been_made.once
    expect(result).to eq(Extractor::NoData)
  end
end