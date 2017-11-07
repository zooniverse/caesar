require 'rails_helper'

RSpec.describe ExtractWorker, type: :worker do
  let(:workflow) { create :workflow }
  let(:subject) { create :subject }

  it 'works with classification ids' do
    classification = create :classification, workflow: workflow, subject: subject
    described_class.new.perform(classification.id)
  end

  it 'marks the classification as processed' do
    classification = create :classification, workflow: workflow, subject: subject
    expect do
      described_class.new.perform(classification.id)
    end.to change { Classification.count }.from(1).to(0)
  end
end
