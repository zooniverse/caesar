require 'spec_helper'

RSpec.describe ExtractWorker, type: :worker do
  let(:workflow) { create :workflow }
  let(:subject) { create :subject }

  it 'works with classification ids' do
    classification = create :classification, workflow: workflow, subject: subject
    described_class.new.perform(classification.id)
  end

  it 'does extract when the workflow is active' do
    active_workflow = create :workflow, status: :active
    classification = create :classification, workflow: active_workflow, subject: subject

    dbl = instance_double(RunsExtractors, extract: [])
    allow_any_instance_of(Workflow).to receive(:extractors_runner).and_return(dbl)

    described_class.new.perform(classification.id)

    expect(dbl).to have_received(:extract)
  end

  it 'does not extract when the workflow is paused' do
    paused_workflow = create :workflow, status: :paused
    classification = create :classification, workflow: paused_workflow, subject: subject

    dbl = instance_double(RunsExtractors, extract: [])
    allow_any_instance_of(Workflow).to receive(:extractors_runner).and_return(dbl)

    described_class.new.perform(classification.id)

    expect(dbl).not_to have_received(:extract)
  end

  it 'does not extract when the workflow is halted' do
    halted_workflow = create :workflow, status: :halted
    classification = create :classification, workflow: halted_workflow, subject: subject

    dbl = instance_double(RunsExtractors, extract: [])
    allow_any_instance_of(Workflow).to receive(:extractors_runner).and_return(dbl)

    described_class.new.perform(classification.id)

    expect(dbl).not_to have_received(:extract)
  end

  it 'queues the classification to be deleted' do
    classification = create :classification, workflow: workflow, subject: subject
    expect do
      described_class.new.perform(classification.id)
    end.to change(DeleteClassificationWorker.jobs, :size).by(1)
  end

  context 'when classification is not in DB' do
    it 'ignores error' do
      extract = create :extract
      expect do
        described_class.new.perform(extract.classification_id)
      end.not_to raise_error
    end
  end
end
