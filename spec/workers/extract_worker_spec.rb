require 'rails_helper'

RSpec.describe ExtractWorker, type: :worker do
  let(:workflow) { create :workflow }
  let(:subject) { create :subject }

  it 'works with legacy jobs' do
    classification_data = {
      "workflow_version" => "1.2",
      "annotations" => {},
      "links" => {
        "project" => workflow.project_id,
        "workflow" => workflow.id,
        "subjects" => [subject.id]
      }
    }

    described_class.new.perform(workflow.id, classification_data)
  end

  it 'works with classification ids' do
    classification = Classification.create!(
      "workflow_version" => "1.2",
      "annotations" => {},
      "links" => {
        "project" => workflow.project_id,
        "workflow" => workflow.id,
        "subjects" => [subject.id]
      }
    )

    described_class.new.perform(classification.id)
  end
end
