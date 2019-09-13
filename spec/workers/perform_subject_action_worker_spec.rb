require 'spec_helper'

RSpec.describe PerformSubjectActionWorker, type: :worker do
  let(:workflow) { create :workflow }
  let(:subject) { create :subject }

  it 'performs action when the workflow is active' do
    active_workflow = create :workflow, status: :active
    create :subject_rule, workflow: active_workflow
    action = create :subject_action, workflow: active_workflow

    dbl = instance_double(SubjectAction, perform: nil, workflow: active_workflow)

    allow(SubjectAction).to receive(:find).and_return(dbl)

    described_class.new.perform(action.id)

    expect(dbl).to have_received(:perform)
  end

  it 'performs action when the workflow is paused' do
    paused_workflow = create :workflow, status: :paused
    create :subject_rule, workflow: paused_workflow
    action = create :subject_action, workflow: paused_workflow

    dbl = instance_double(SubjectAction, perform: nil, workflow: paused_workflow)

    allow(SubjectAction).to receive(:find).and_return(dbl)

    described_class.new.perform(action.id)

    expect(dbl).to have_received(:perform)
  end

  it 'does not perform action when the workflow is halted' do
    paused_workflow = create :workflow, status: :paused
    create :subject_rule, workflow: paused_workflow
    action = create :subject_action, workflow: paused_workflow

    dbl = instance_double(SubjectAction, perform: nil, workflow: paused_workflow)

    allow(SubjectAction).to receive(:find).and_return(dbl)

    described_class.new.perform(action.id)

    expect(dbl).to have_received(:perform)
  end

end