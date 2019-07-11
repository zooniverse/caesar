require 'spec_helper'

class DummyWorker
  include Sidekiq::Worker

  def perform(id)
  end
end

RSpec.describe DeferredQueue do
  it 'commits added jobs' do
    queue = described_class.new

    queue.add(
      'queue' => 'q',
      'class' => DummyWorker,
      'args' => [1]
    )

    queue.add(
      'queue' => 'q',
      'class' => DummyWorker,
      'args' => [2]
    )

    allow(Sidekiq::Client).to receive(:push).and_return(:true)

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
