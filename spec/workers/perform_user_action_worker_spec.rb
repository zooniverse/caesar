require 'spec_helper'

RSpec.describe PerformUserActionWorker, type: :worker do
  let(:workflow) { create :workflow }

  it 'performs action when the workflow is active' do
    active_workflow = create :workflow, status: :active
    create :user_rule, workflow: active_workflow
    action = create :user_action, workflow: active_workflow, user_id: 1234, effect_type: 'promote_user'

    dbl = instance_double(UserAction, perform: nil, workflow: active_workflow)

    allow(UserAction).to receive(:find).and_return(dbl)

    described_class.new.perform(action.id)

    expect(dbl).to have_received(:perform)
  end

  it 'performs action when the workflow is paused' do
    paused_workflow = create :workflow, status: :paused
    create :user_rule, workflow: paused_workflow
    action = create :user_action, workflow: paused_workflow, user_id: 1234, effect_type: 'promote_user'

    dbl = instance_double(UserAction, perform: nil, workflow: paused_workflow)

    allow(UserAction).to receive(:find).and_return(dbl)

    described_class.new.perform(action.id)

    expect(dbl).to have_received(:perform)
  end

  it 'does not perform action when the workflow is halted' do
    halted_workflow = create :workflow, status: :halted
    create :user_rule, workflow: halted_workflow
    action = create :user_action, workflow: halted_workflow, user_id: 1234, effect_type: 'promote_user'

    dbl = instance_double(UserAction, perform: nil, workflow: halted_workflow)

    allow(UserAction).to receive(:find).and_return(dbl)

    described_class.new.perform(action.id)

    expect(dbl).not_to have_received(:perform)
  end

end