require 'spec_helper'

RSpec.describe DeferredQueue do
  let(:worker) { double(perform_in: true) }

  it 'commits added jobs' do
    queue = described_class.new
    queue.add(worker, 1)
    queue.add(worker, 2)
    queue.commit

    expect(worker).to have_received(:perform_in).twice
  end
end
