require 'rails_helper'

RSpec.describe Action, type: :model do
  describe '#perform' do
    let(:workflow) { Workflow.create! }
    let(:subject) { Subject.create! }

    it 'performs the effect' do
      expect_any_instance_of(Effects::RetireSubject).to receive(:perform).with(workflow.id, subject.id)

      action = Action.new(effect_type: 'retire_subject', workflow_id: workflow.id, subject_id: subject.id)
      action.perform
    end

    it 'marks the action as performed' do
      allow_any_instance_of(Effects::RetireSubject).to receive(:perform)

      action = Action.new(effect_type: 'retire_subject', workflow_id: workflow.id, subject_id: subject.id)
      action.perform
      expect(action.status).to eq('completed')
      expect(action.completed_at).to be_present
    end
  end
end
