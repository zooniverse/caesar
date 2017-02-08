require 'spec_helper'

describe FetchClassificationsWorker do

  let(:panoptes) { double("PanoptesAdapter", get_subject_classifications: []) }

  before do
    allow(Effects).to receive(:panoptes).and_return(panoptes)
  end

  it 'calls the API' do
    FetchClassificationsWorker.new.perform(1234,5678)
    expect(panoptes).to have_received(:get_subject_classifications)
      .with(1234,5678)
  end

  it 'queues up the results' do
    expect do
      FetchClassificationsWorker.new.process_classifications(5678, [1, 2, 3])
    end.to change(ExtractWorker.jobs, :size).by(3)
  end

end
