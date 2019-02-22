require 'spec_helper'

describe Extractors::ExternalExtractor do
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

  let(:response_data) { {"foo" => "bar"} }

  before do
    stub_request(:post, "https://example.org/post/classification/here").
      with(:body => classification.to_json,
           :headers => {'Accept'=>'application/json',
                        'Content-Type'=>'application/json',
                        'Host'=>'example.org'}).
      to_return(:status => 200, :body => response_data.to_json, :headers => {})
  end

  it 'posts the classification to a foreign API' do
    extractor = described_class.new(key: "ext", config: {"url" => "https://example.org/post/classification/here"}, workflow: workflow)
    extractor.process(classification)

    expect(a_request(:post, "https://example.org/post/classification/here")
             .with(body: classification.to_json))
      .to have_been_made.once
  end

  it 'stores the returned data as an extract' do
    extractor = described_class.new(key: "ext", config: {"url" => "https://example.org/post/classification/here"}, workflow: workflow)
    result = extractor.process(classification)
    expect(result).to eq(response_data)
  end

  it 'handles 204s' do
    stub_request(:post, "https://example.org/post/classification/here").
      to_return(status: 204, body: "", headers: {})

    extractor = described_class.new(key: "ext", config: {"url" => "https://example.org/post/classification/here"}, workflow: workflow)
    result = extractor.process(classification)
    expect(result).to eq(Extractor::NoData)
  end

  it 'handles 500s' do
    stub_request(:post, "https://example.org/post/classification/here").
      to_return(status: 500, body: "", headers: {})

    extractor = described_class.new(key: "ext", config: {"url" => "https://example.org/post/classification/here"}, workflow: workflow)
    expect{extractor.process(classification)}.to raise_error(Extractors::ExternalExtractor::ExternalExtractorFailed)
  end
end
