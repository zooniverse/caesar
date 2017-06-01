require 'spec_helper'

describe NotifyWebhookWorker do
  let(:sample_data) {
    { "foo" => "bar" }
  }

  before do
    stub_request(:post, "http://example.org/api?event_type=test").
      with(:body => sample_data.to_json,
           :headers => {
             'Content-Type' => 'application/json'
           }).
      to_return(:status => 200)
  end

  it 'notifies the foreign API' do
    described_class.new.perform(
      "http://example.org/api",
      "test",
      sample_data
    )

    expect(a_request(:post, "example.org/api?event_type=test")
            .with(body: sample_data.to_json))
      .to have_been_made.once
  end

  it 'does not post if no endpoint is defined' do
    described_class.new.perform("", "test", sample_data)
    described_class.new.perform(nil, "test", sample_data)

    expect(a_request(:post, "example.org/api?event_type=test")
            .with(body: sample_data.to_json))
      .not_to have_been_made
  end
end
