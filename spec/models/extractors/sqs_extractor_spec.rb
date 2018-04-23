require 'spec_helper'

describe Extractors::SqsExtractor do
  subject(:extractor) { described_class.new config: {"queue_name" => "CaesarSpaceWarpsStaging"}}
  let(:subject) { create :subject }
  let(:classifications) {[
    build(:classification, id: 1, subject_id: subject.id),
    build(:classification, id: 2, subject_id: subject.id)
  ]}

  it 'calculates url correctly' do
    r = described_class.new config: {"queue_url" => "some_url"}
    expect(r.queue_url).to eq("some_url")

    r = described_class.new config: {"queue_url" => "some_url", "queue_name" => "some_name"}
    expect(r.queue_url).to eq("some_url")

    r = described_class.new config: { "queue_name" => "some name" }
    mock_result = instance_double(Aws::SQS::Types::GetQueueUrlResult, queue_url: "retrieved url")
    sqs_double = instance_double(Aws::SQS::Client, get_queue_url: mock_result)
    expect(r).to receive(:sqs_client).and_return(sqs_double)
    expect(r.queue_url).to eq("retrieved url")
    expect(sqs_double).to have_received(:get_queue_url).with(queue_name: "some name").once
  end

  it 'sends classifications to the queue' do
    sqs_double = instance_double(Aws::SQS::Client, send_message: nil)
    expect(extractor).to receive(:sqs_client).and_return(sqs_double)
    expect(extractor).to receive(:queue_url).and_return("a_url")

    result = extractor.extract_data_for(classifications[0])

    expect(result).to eq("dispatched")
    expect(sqs_double).to have_received(:send_message).once.with({
      "message_deduplication_id" => 1,
      "message_body" => classifications[0].to_json,
      "queue_url" => "a_url"
    })
  end
end