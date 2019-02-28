require 'spec_helper'

describe Reducers::SqsReducer do
  subject(:reducer) { described_class.new config: {"queue_name" => "CaesarSpaceWarpsStaging"}}
  let(:extracts) {
    [
        build(:extract, id: 1, classification_at: nil),
        build(:extract, id: 2, classification_at: nil)
    ]
  }

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

  it 'prepares extract correctly' do
    hash = reducer.prepare_extract(extracts.first)
    expect(hash).to include("id")
    expect(hash).to include("classification_at")
    expect(hash).not_to include("created_at")
  end

  it 'sends the extracts to the queue' do
    sqs_double = instance_double(Aws::SQS::Client, send_message: nil)
    expect(reducer).to receive(:sqs_client).twice.and_return(sqs_double)
    expect(reducer).to receive(:queue_url).twice.and_return("a_url")

    reduction = build(:subject_reduction)
    reducer.reduce_into(extracts, reduction)

    expect(reduction.data).to eq("dispatched")
    expect(sqs_double).to have_received(:send_message).once.with(
      message_body: reducer.prepare_extract(extracts[0]).to_json,
      queue_url: "a_url"
    )

    expect(sqs_double).to have_received(:send_message).once.with(
      message_body: reducer.prepare_extract(extracts[1]).to_json,
      queue_url: "a_url"
    )
  end

  it 'doesnt crash when queue_url is unset and requested and no queue_name set' do
    r = described_class.new config: { queue_name: nil, queue_url: nil }
    expect{ r.queue_url }.not_to raise_exception
  end
end