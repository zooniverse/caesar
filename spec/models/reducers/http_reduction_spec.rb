require 'spec_helper'

class DummyReducer
  include Reducers::HttpReduction

  attr_reader :url

  def initialize(url: 'https://example.org/post/here')
    @url = url
  end
end

describe Reducers::HttpReduction do
  let(:default_reducer){ DummyReducer.new }
  let(:sample_url){ 'https://example.org/post/here' }
  let(:workflow){ build :workflow }
  let(:subject){ build :subject }
  let(:reduction){ build :subject_reduction, reducible: workflow, subject: subject }

  it 'still validates the url' do
    broken_reducer = DummyReducer.new url: 'http://www.google.com'
    expect(broken_reducer).not_to be_valid
  end

  it 'calls http_post correctly' do
    expect(default_reducer).to receive(:http_post).with("test").once
    default_reducer.http_reduce(reduction, "test")
  end

  it 'returns the correct value for no data' do
    stub_request(:post, sample_url).
      to_return(status: 204, body: "", headers: {})

    expect(default_reducer.http_reduce(reduction, nil).data).to eq(nil)
  end

  it 'configures HttpOperation with the correct exception type' do
    allow(RestClient).to receive(:post).and_raise(RestClient::Exception)

    expect do
      default_reducer.http_reduce(reduction, nil)
    end.to raise_error(Reducers::HttpReduction::ReductionFailed)
  end
end