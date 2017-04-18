require 'spec_helper'

describe FetchClassificationsWorker do

  let(:panoptes) { double("PanoptesAdapter", get_subject_classifications: {"classifications" => []}) }

  before do
    allow(Effects).to receive(:panoptes).and_return(panoptes)
  end

  it 'calls the API' do
    FetchClassificationsWorker.new.perform(1234,5678)
    expect(panoptes).to have_received(:get_subject_classifications)
      .with(1234,5678)
  end

  it 'queues up the results' do
    allow(panoptes).to receive(:get_subject_classifications).and_return("classifications" => [{"id" => 1}, {"id" => 2}, {"id" => 3}])

    expect do
      FetchClassificationsWorker.new.perform(1234, 5678)
    end.to change(ExtractWorker.jobs, :size).by(3)
  end

end
