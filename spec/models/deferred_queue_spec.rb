require 'spec_helper'

describe DeferredQueue do
  let(:worker){ double(perform_async: true, set: self) }
  it 'commits added jobs' do
    queue = described_class.new

    queue.add(worker, nil, 1)
    queue.add(worker, nil, 2)

    queue.commit

    expect(worker).to have_received(:perform_async).with(1).ordered
    expect(worker).to have_received(:perform_async).with(2).ordered
    expect(worker).not_to have_received(:set)
  end

  it 'commits and enqueues added jobs to a custom queue if asked' do
    actual_worker = DescribeWorkflowWorker
    queue = described_class.new
    queue.add(actual_worker, 'custom', 1)

    expect{
      queue.commit
    }.to change{Sidekiq::Queues["custom"].size}.by(1)
  end
end
