require 'spec_helper'

describe Reducers::ExternalReducer do
  def unwrap(reduction)
    reduction['_default']
  end

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
           :headers => {'Accept'=>'application/json',
                        'Content-Type'=>'application/json',
                        'Host'=>'example.org'})
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
    expect(unwrap(result)).to eq(response_data)
  end

  it 'handles 204s' do
    stub_request(:post, "http://example.org/post/extracts/here").
      to_return(status: 204, body: "", headers: {})

    extractor = described_class.new("red", "url" => "http://example.org/post/extracts/here")
    result = extractor.process(extracts)
    expect(unwrap(result)).to eq(Reducers::Reducer.NoData)
  end

  it 'does not post if no url is configured' do
    reducer = described_class.new("red", url: nil)

    expect do
      reducer.process(classification)
    end.to raise_error(StandardError)
  end

end
