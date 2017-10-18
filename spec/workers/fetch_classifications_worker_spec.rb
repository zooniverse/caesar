require 'spec_helper'

describe FetchClassificationsWorker do
  let(:workflow) { create :workflow }
  let(:subject)  { create :subject }

  let(:panoptes) { double("PanoptesAdapter", get_subject_classifications: {"classifications" => []}) }

  before do
    allow(Effects).to receive(:panoptes).and_return(panoptes)
  end

  it 'calls the API' do
    FetchClassificationsWorker.new.perform(1234,5678)
    expect(panoptes).to have_received(:get_subject_classifications)
      .with(1234,5678)
  end

  it 'stores classifications in the DB' do
    classifications = [classification(1), classification(2), classification(3)]
    allow(panoptes).to receive(:get_subject_classifications).and_return("classifications" => classifications)

    expect do
      FetchClassificationsWorker.new.perform(1234, 5678)
    end.to change(Classification, :count).by(3)
  end

  it 'queues up the results' do
    classifications = [classification(1), classification(2), classification(3)]
    allow(panoptes).to receive(:get_subject_classifications).and_return("classifications" => classifications)

    expect do
      FetchClassificationsWorker.new.perform(1234, 5678)
    end.to change(ExtractWorker.jobs, :size).by(3)
  end

  def classification(id)
    {
      "id" => id,
      "annotations" => {},
      "metadata" => {},
      "workflow_version" => "1.1",
      "links" => {
        "project" => workflow.project_id,
        "workflow" => workflow.id,
        "subjects" => [subject.id]
      }
    }
  end

end
