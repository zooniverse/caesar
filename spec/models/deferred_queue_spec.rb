require 'spec_helper'

describe DeferredQueue do
  let(:worker){ double(perform_async: true) }
  it 'commits added jobs' do
    queue = described_class.new

    queue.add(worker, 1)
    queue.add(worker, 2)

    queue.commit

    expect(Sidekiq::Client).to have_received(:push).with(
      'queue' => 'q',
      'class' => DummyWorker,
      'args' => [1]
    ).ordered

    expect(Sidekiq::Client).to have_received(:push).with(
      'queue' => 'q',
      'class' => DummyWorker,
      'args' => [2]
    ).ordered
  end
end
