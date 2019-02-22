require 'spec_helper'

class DummyExtractor
  include Extractors::HttpExtraction

  attr_reader :url

  def initialize(url: 'https://example.org/post/here')
    @url = url
  end
end

describe Extractors::HttpExtraction do
  let(:default_extractor){ DummyExtractor.new }
  let(:sample_url){ 'https://example.org/post/here' }

  it 'still validates the url' do
    broken_extractor = DummyExtractor.new url: 'http://www.google.com'
    expect(broken_extractor).not_to be_valid
  end

  it 'calls http_post correctly' do
    expect(default_extractor).to receive(:http_post).with("test").once
    default_extractor.http_extract("test")
  end

  it 'returns the correct value for no data' do
    stub_request(:post, sample_url).
      to_return(status: 204, body: "", headers: {})

    expect(default_extractor.http_extract(nil)).to eq(Extractor::NoData)
  end

  it 'configures HttpOperation with the correct exception type' do
    allow(RestClient).to receive(:post).and_raise(RestClient::Exception)

    expect do
      default_extractor.http_extract(nil)
    end.to raise_error(Extractors::HttpExtraction::ExtractionFailed)
  end
end