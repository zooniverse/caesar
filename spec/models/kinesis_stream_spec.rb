require 'spec_helper'

RSpec.describe KinesisStream do
  let(:kinesis_stream) { KinesisStream.new }
  let(:event1) { double.as_null_object }
  let(:event2) { double.as_null_object }
  let(:payload) { [event1, event2] }

  it 'processes each item in the payload' do
    expect(StreamEvents).to receive(:from).with(kinesis_stream, event1).ordered.and_return(double(process: true))
    expect(StreamEvents).to receive(:from).with(kinesis_stream, event2).ordered.and_return(double(process: true))
    kinesis_stream.receive(payload)
  end

  it 'flushes the queue of deferred jobs to Sidekiq' do
    expect_any_instance_of(DeferredQueue).to receive(:commit)
    kinesis_stream.receive(payload)
  end
end
