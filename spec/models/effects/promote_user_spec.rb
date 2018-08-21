require 'spec_helper'

describe Effects::PromoteUser do
  let(:workflow) { create :workflow, project_id: 1234 }
  let(:target_workflow_id) { 20004 }
  let(:user_id) { 33333 }

  let(:panoptes) { double("PanoptesAdapter", promote_user_to_workflow: true) }
  let(:effect) { described_class.new("workflow_id" => target_workflow_id) }

  before do
    allow(Effects).to receive(:panoptes).and_return(panoptes)
  end

  it 'promotes the user to the specified workflow' do
    effect.perform(workflow.id, user_id)
    expect(panoptes).to have_received(:promote_user_to_workflow)
      .with(user_id, workflow.project_id, target_workflow_id)
  end
end
