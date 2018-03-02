require 'spec_helper'

describe Reducers::ExternalReducer do
  def unwrap(reduction)
    reduction[0][:data]
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
    reducer = described_class.new(config: {"url" => "http://example.org/post/extracts/here"})
    reducer.process(extracts)

    expect(a_request(:post, "example.org/post/extracts/here")
            .with(body: extracts.to_json))
      .to have_been_made.once
  end

  it 'passes through the result from the foreign API' do
    extractor = described_class.new(config: {"url" => "http://example.org/post/extracts/here"})
    result = extractor.process(extracts)
    expect(unwrap(result)).to eq(response_data)
  end

  it 'handles 204s' do
    stub_request(:post, "http://example.org/post/extracts/here").
      to_return(status: 204, body: "", headers: {})

    extractor = described_class.new(config: {"url" => "http://example.org/post/extracts/here"})
    result = extractor.process(extracts)
    expect(unwrap(result)).to eq(Reducer::NoData)
  end

  it 'does not post if no url is configured' do
    reducer = described_class.new(config: {"url" => nil})

    expect do
      reducer.process(classification)
    end.to raise_error(StandardError)
  end

  describe 'validations' do
    it 'is not valid with a non-https url' do
      reducer = described_class.new(config: {"url" => "http://foo.com"})
      expect(reducer).not_to be_valid
      expect(reducer.errors[:url]).to be_present
    end

    it 'is not valid with some strange url' do
      reducer = described_class.new(config: {"url" => "https:\\foo+3"})
      expect(reducer).not_to be_valid
      expect(reducer.errors[:url]).to include("URL could not be parsed")
    end
  end
end
