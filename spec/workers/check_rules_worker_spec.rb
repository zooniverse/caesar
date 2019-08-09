require 'spec_helper'

RSpec.describe CheckRulesWorker, type: :worker do
  let(:workflow) { create :workflow }
  let(:subject) { create :subject }

  it 'checks rules when the workflow is active' do
    active_workflow = create :workflow, status: :active
    create :subject_rule, workflow: active_workflow

    dbl = instance_double(RunsRules, check_rules: [])
    allow_any_instance_of(Workflow).to receive(:rules_runner).and_return(dbl)

    described_class.new.perform(active_workflow.id, 'Workflow', subject.id, nil)

    expect(dbl).to have_received(:check_rules)
  end

  it 'checks rules when the workflow is paused' do
    paused_workflow = create :workflow, status: :paused
    create :subject_rule, workflow: paused_workflow

    dbl = instance_double(RunsRules, check_rules: [])
    allow_any_instance_of(Workflow).to receive(:rules_runner).and_return(dbl)

    described_class.new.perform(paused_workflow.id, 'Workflow', subject.id, nil)

    expect(dbl).to have_received(:check_rules)
  end

  it 'does not check rules when the workflow is halted' do
    halted_workflow = create :workflow, status: :halted
    create :subject_rule, workflow: halted_workflow

    dbl = instance_double(RunsRules, check_rules: [])
    allow_any_instance_of(Workflow).to receive(:rules_runner).and_return(dbl)

    described_class.new.perform(halted_workflow.id, 'Workflow', subject.id, nil)

    expect(dbl).not_to have_received(:check_rules)
  end

end