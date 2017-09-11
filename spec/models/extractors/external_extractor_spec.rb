require 'spec_helper'

describe Extractors::ExternalExtractor do
  let(:classification) do
    Classification.new(
      "id" => "12329",
      "annotations" => [{"task" => "T0", "value" => "foo"}],
      "metadata" => {},
      "created_at" => "",
      "updated_at" => "",
      "links" => {"project" => "1232", "workflow" => "1021", "subjects" => ["3999"], "user" => nil}
    )
  end

  let(:response_data) { {"foo" => "bar"} }

  before do
    stub_request(:post, "http://example.org/post/classification/here").
      with(:body => classification.to_json,
           :headers => {'Accept'=>'application/json',
                        'Content-Type'=>'application/json',
                        'Host'=>'example.org'}).
      to_return(:status => 200, :body => response_data.to_json, :headers => {})
  end

  it 'posts the classification to a foreign API' do
    extractor = described_class.new(key: "ext", config: {"url" => "http://example.org/post/classification/here"})
    extractor.process(classification)

    expect(a_request(:post, "example.org/post/classification/here")
             .with(body: classification.to_json))
      .to have_been_made.once
  end

  it 'stores the returned data as an extract' do
    extractor = described_class.new(key: "ext", config: {"url" => "http://example.org/post/classification/here"})
    result = extractor.process(classification)
    expect(result).to eq(response_data)
  end

  it 'handles 204s' do
    stub_request(:post, "http://example.org/post/classification/here").
      to_return(status: 204, body: "", headers: {})

    extractor = described_class.new(key: "ext", config: {"url" => "http://example.org/post/classification/here"})
    result = extractor.process(classification)
    expect(result).to eq(Extractor::NoData)
  end

  it 'does not post if no url is configured' do
    extractor = described_class.new(key: "ext")

    expect do
      extractor.process(classification)
    end.to raise_error(StandardError)
  end
end
