require 'rails_helper'

RSpec.describe ExtractWorker, type: :worker do
  let(:workflow) { create :workflow }
  let(:subject) { create :subject }

  it 'works with legacy jobs' do
    classification_data = build(:classification_event, workflow: workflow, subject: subject)

    described_class.new.perform(workflow.id, classification_data)
  end

  it 'works with classification ids' do
    classification = create :classification, workflow: workflow, subject: subject
    described_class.new.perform(classification.id)
  end
end
