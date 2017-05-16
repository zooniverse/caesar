require 'spec_helper'

RSpec.describe DeferredQueue do
  let(:worker) { double(perform_async: true) }

  it 'commits added jobs' do
    queue = described_class.new
    queue.add(worker, 1)
    queue.add(worker, 2)
    queue.commit

    expect(worker).to have_received(:perform_async).with(1).ordered
    expect(worker).to have_received(:perform_async).with(2).ordered
  end
end
