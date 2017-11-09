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

  context 'when classification is not in DB' do
    it 'ignores error if extract exists' do
      extract = create :extract
      expect do
        described_class.new.perform(extract.classification_id)
      end.not_to raise_error
    end

    it 'reraises error if no extracts exist' do
      expect do
        described_class.new.perform(1)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
