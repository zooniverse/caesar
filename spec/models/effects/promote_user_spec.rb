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

  it 'has initial stoplight_color of green' do
    effect.perform(workflow.id, user_id)
    expect(effect.stoplight_color).to eq(Stoplight::Color::GREEN)
  end

  describe 'failure' do
    it 'does not attempt the call on repeated failures' do
      allow(panoptes).to receive(:promote_user_to_workflow)
        .and_raise(Panoptes::Client::ServerError.new('Another error'))
      3.times do
        expect { effect.perform(workflow.id, user_id) }
          .to raise_error(Panoptes::Client::ServerError)
      end
      expect { effect.perform(workflow.id, user_id) }
        .to raise_error(Stoplight::Error::RedLight)

      expect(effect.stoplight_color).to eq(Stoplight::Color::RED)
    end
  end
end
