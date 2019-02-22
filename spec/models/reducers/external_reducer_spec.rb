require 'spec_helper'

describe Reducers::ExternalReducer do
  let(:valid_url){ "https://example.org/post/extracts/here" }
  let(:workflow) { create :workflow }
  let(:subject) { create :subject}
  let(:reducer) { described_class.new(
    key: 'external',
    reducible_id: workflow.id,
    reducible_type: 'Workflow',
    config: { "url" => valid_url }
  )}

  let(:extracts) {
    [
      Extract.new(data: {"foo" => "bar"}, workflow: workflow, subject: subject, user_id: 123),
      Extract.new(data: {"foo" => "baz"}, workflow: workflow, subject: subject, user_id: 123)
    ]
  }

  let(:response_data) { {"result" => {"bar" => 1, "baz" => 1}} }

  before do
    stub_request(:post, valid_url)
      .with(:body => extracts.to_json,
           :headers => {'Accept'=>'application/json',
                        'Content-Type'=>'application/json',
                        'Host'=>'example.org'})
      .to_return(:status => 200, :body => response_data.to_json, :headers => {})
  end

  it 'posts the extracts to a foreign API' do
    reducer.reduce_into(extracts, build(:subject_reduction))

    expect(a_request(:post, valid_url)
            .with(body: extracts.to_json))
      .to have_been_made.once
  end

  it 'passes through the result from the foreign API' do
    result = reducer.reduce_into(extracts, build(:subject_reduction))
    expect(result.data).to eq(response_data)
  end

  it 'handles 204s' do
    stub_request(:post, valid_url).
      to_return(status: 204, body: "", headers: {})

    result = reducer.reduce_into(extracts, build(:subject_reduction))
    expect(result.data).to be(nil)
  end

  it 'does not post if no url is configured' do
    reducer = described_class.new(config: {"url" => nil})

    expect do
      reducer.reduce_into(extracts, build(:subject_reduction))
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

  describe 'running_reduction' do
    let(:running_reducer){ reducer.tap{ |r| r.running_reduction! } }
    let(:store){ {"foo" => "bar"} }

    let(:running_reduction) { create(
      :subject_reduction,
      reducer_key: running_reducer.key,
      store: store
    ) }

    let(:request_data){{
      extracts: extracts,
      store: running_reduction.store
    }}

    it 'sends the extracts and the store' do
      stub_request(:post, valid_url)
        .with(:headers => {'Accept'=>'application/json',
                          'Content-Type'=>'application/json',
                          'Host'=>'example.org'})
        .to_return(:status => 200, :body => request_data.to_json, :headers => {})

      reducer.reduce_into(extracts, running_reduction)
      expect(a_request(:post, valid_url)
              .with(body: request_data.to_json))
        .to have_been_made.once
    end

    it 'transparently handles the _store' do
      return_store = store.clone.merge("bar" => "baz")
      running_response_data = response_data.merge("_store" => return_store)

      stub_request(:post, valid_url)
        .with(:headers => {'Accept'=>'application/json',
                          'Content-Type'=>'application/json',
                          'Host'=>'example.org'})
        .to_return(:status => 200, :body => running_response_data.to_json, :headers => {})

      reducer.reduce_into(extracts, running_reduction)
      expect(running_reduction.store).to have_key('bar')
    end
  end
end