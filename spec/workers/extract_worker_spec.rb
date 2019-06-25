require 'rails_helper'

RSpec.describe ExtractWorker, type: :worker do
  let(:workflow) { create :workflow }
  let(:subject) { create :subject }

  it 'works with classification ids' do
    classification = create :classification, workflow: workflow, subject: subject
    described_class.new.perform(classification.id)
  end

  it 'queues the classification to be deleted' do
    classification = create :classification, workflow: workflow, subject: subject
    expect do
      described_class.new.perform(classification.id)
    end.to change(DeleteClassificationWorker.jobs, :size).by(1)
  end

  context 'when classification is not in DB' do
    it 'ignores error if extract exists' do
      extract = create :extract
      expect do
        described_class.new.perform(extract.classification_id)
      end.not_to raise_error
    end

    it 'no longer raises error even if no extracts exist' do
      expect do
        described_class.new.perform(-1)
      end.not_to raise_error
    end
  end
end
