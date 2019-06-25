require 'spec_helper'

describe DeleteClassificationWorker do
  it 'deletes the classification if it exists' do
    workflow = create :workflow
    subject = create :subject
    classification = create :classification, workflow: workflow, subject: subject

    described_class.new.perform(classification.id)
    expect(Classification.find_by_id(classification.id)).to be_nil
  end

  it 'does nothing if the classification is gone' do
    expect do
      described_class.new.perform(-1)
    end.not_to raise_error
  end
end
