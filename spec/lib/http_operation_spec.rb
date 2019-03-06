require 'spec_helper'

class DummyException < StandardError; end

class DummyHttpOperationHost
  include HttpOperation

  attr_reader :url

  def initialize(url: 'https://example.org/post/here')
    @url = url
  end

  def no_data
    "no data"
  end

  def operation_failed_type
    DummyException
  end
end

describe HttpOperation do
  let(:default_host){ DummyHttpOperationHost.new }
  let(:sample_url){ 'https://example.org/post/here' }

  describe 'validates urls' do
    it 'accepts valid, secure urls' do
      expect(default_host).to be_valid
    end

    it 'rejects insecure urls' do
      mixin_host = DummyHttpOperationHost.new url: 'http://example.org/post/here'
      expect(mixin_host).not_to be_valid
    end
  end

  describe 'response handling' do
    it 'does not post if the url is empty' do
      mixin_host = DummyHttpOperationHost.new url: nil

      expect do
        mixin_host.http_post(nil)
      end.to raise_error(HttpOperation::ConfigurationError)
    end

    it 'serializes the payload' do
      sample_hash = { foo: 'bar' }
      stub_request(:post, sample_url).
        to_return(status: 204, body: sample_hash.to_json, headers: {})

      default_host.http_post(sample_hash)

      expect(a_request(:post, sample_url)
              .with(body: sample_hash.to_json))
        .to have_been_made.once
    end

    it 'unpacks the response if successful' do
      sample_hash = { foo: 'bar' }.with_indifferent_access
      stub_request(:post, sample_url).
        to_return(status: 200, body: sample_hash.to_json, headers: {})

      expect(default_host.http_post(nil)).to eq(sample_hash)
    end

    it 'handles 204s by returning no_data' do
      stub_request(:post, sample_url).
        to_return(status: 204, body: "", headers: {})

      expect(default_host.http_post(nil)).to eq("no data")
    end

    it 'handles missing endpoints' do
      stub_request(:post, sample_url).
        to_return(status: 404, body: "", headers: {})

      expect do
        default_host.http_post(nil)
      end.to raise_error(HttpOperation::NotFound)
    end

    it 'handles 500s' do
      stub_request(:post, sample_url).
        to_return(status: 500, body: "", headers: {})

      expect do
        default_host.http_post(nil)
      end.to raise_error(DummyException)
    end

    it 'handles weird response codes' do
      stub_request(:post, sample_url).
        to_return(status: 999, body: "", headers: {})

      expect do
        default_host.http_post(nil)
      end.to raise_error(DummyException)
    end
  end
end