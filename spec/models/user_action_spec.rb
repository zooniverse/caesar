require 'rails_helper'

RSpec.describe UserAction, type: :model do
  describe '#perform' do
    let(:workflow) { create :workflow }
    let(:user_id){ 1234 }

    it 'performs the effect' do
      expect_any_instance_of(Effects::PromoteUser).to receive(:perform).with(workflow.id, user_id)

      action = UserAction.new(effect_type: 'promote_user', workflow_id: workflow.id, user_id: user_id)
      action.perform
    end
  end
end
