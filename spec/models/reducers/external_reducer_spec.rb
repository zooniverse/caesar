require 'spec_helper'

describe Reducers::ExternalReducer do
  let(:extracts) {
    [
      Extract.new(data: {"foo" => "bar"}),
      Extract.new(data: {"foo" => "baz"})
    ]
  }

  let(:response_data) { {"result" => {"bar" => 1, "baz" => 1}} }

  before do
    stub_request(:post, "http://example.org/post/extracts/here")
      .with(:body => extracts.to_json,
           :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'Host'=>'example.org', 'User-Agent'=>'Ruby'})
      .to_return(:status => 200, :body => response_data.to_json, :headers => {})
  end

  it 'posts the extracts to a foreign API' do
    reducer = described_class.new("red", "url" => "http://example.org/post/extracts/here")
    reducer.process(extracts)

    expect(a_request(:post, "example.org/post/extracts/here")
            .with(body: extracts.to_json))
      .to have_been_made.once
  end

  it 'passes through the result from the foreign API' do
    extractor = described_class.new("red", "url" => "http://example.org/post/extracts/here")
    result = extractor.process(extracts)
    expect(result).to eq(response_data)
  end

  it 'does not post if no url is configured' do
    reducer = described_class.new("red", url: nil)
    result = reducer.process(extracts)

    expect(result).to eq({})
    expect(a_request(:post, "example.org/post/extracts/here")
            .with(body: extracts.to_json))
      .not_to have_been_made
  end

end
