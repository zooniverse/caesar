require 'spec_helper'

describe FetchClassificationsWorker do
  let(:workflow) { create :workflow }
  let(:subject)  { create :subject }

  let(:panoptes) { double("PanoptesAdapter", get_subject_classifications: {"classifications" => []}) }

  before do
    allow(Effects).to receive(:panoptes).and_return(panoptes)
  end

  it 'calls the API' do
    FetchClassificationsWorker.new.perform(5678, 1234, FetchClassificationsWorker.fetch_for_subject)
    expect(panoptes).to have_received(:get_subject_classifications)
      .with(1234,5678)
  end

  it 'stores classifications in the DB' do
    classifications = [classification(1), classification(2), classification(3)]
    allow(panoptes).to receive(:get_subject_classifications).and_return("classifications" => classifications)

    expect do
      FetchClassificationsWorker.new.perform(5678, 1234, FetchClassificationsWorker.fetch_for_subject)
    end.to change(Classification, :count).by(3)
  end

  it 'queues up the results' do
    classifications = [classification(1), classification(2), classification(3)]
    allow(panoptes).to receive(:get_subject_classifications).and_return("classifications" => classifications)

    expect do
      FetchClassificationsWorker.new.perform(5678, 1234, FetchClassificationsWorker.fetch_for_subject)
    end.to change(ExtractWorker.jobs, :size).by(3)
  end

  def classification(id)
    classification = build(:classification_event, id: id, workflow: workflow, subject: subject)
    classification["metadata"]["workflow_version"] = classification.delete("workflow_version")
    classification
  end
end
