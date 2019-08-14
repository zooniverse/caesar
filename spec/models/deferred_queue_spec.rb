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

  it 'commits added jobs to a custom queue if asked' do
    queue = described_class.new

    queue.add(worker, 'custom', 1)

    queue.commit

    expect(worker).to have_received(:perform_async).with(1)
    expect(worker).to have_received(:set).with(queue: :custom)
  end
end
