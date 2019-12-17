require 'spec_helper'

RSpec.describe CheckUserRulesWorker, type: :worker do
  let(:workflow) { build :workflow }
  let(:user) { double(id: 1) }

  it 'checks rules when the workflow is active' do
    active_workflow = create :workflow, status: :active
    create :user_rule, workflow: active_workflow

    dbl = instance_double(RunsUserRules, check_rules: [])
    allow(RunsUserRules).to receive(:new).and_return(dbl)

    described_class.new.perform(active_workflow.id, 'Workflow', user.id)

    expect(dbl).to have_received(:check_rules)
  end

  it 'checks rules when the workflow is paused' do
    paused_workflow = create :workflow, status: :paused
    create :user_rule, workflow: paused_workflow

    dbl = instance_double(RunsUserRules, check_rules: [])
    allow(RunsUserRules).to receive(:new).and_return(dbl)

    described_class.new.perform(paused_workflow.id, 'Workflow', user.id)

    expect(dbl).to have_received(:check_rules)
  end

  it 'does not check rules when the workflow is halted' do
    halted_workflow = create :workflow, status: :halted
    create :user_rule, workflow: halted_workflow

    dbl = instance_double(RunsUserRules, check_rules: [])
    allow(RunsUserRules).to receive(:new).and_return(dbl)

    described_class.new.perform(halted_workflow.id, 'Workflow', user.id)

    expect(dbl).not_to have_received(:check_rules)
  end

end