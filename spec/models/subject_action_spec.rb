require 'rails_helper'

RSpec.describe SubjectAction, type: :model do
  describe '#perform' do
    let(:workflow) { create :workflow }
    let(:subject) { Subject.create! }

    it 'performs the effect' do
      expect_any_instance_of(Effects::RetireSubject).to receive(:perform).with(workflow.id, subject.id)

      action = SubjectAction.new(effect_type: 'retire_subject', workflow_id: workflow.id, subject_id: subject.id)
      action.perform
    end

    it 'marks the action as completed' do
      allow_any_instance_of(Effects::RetireSubject).to receive(:perform)

      action = SubjectAction.new(effect_type: 'retire_subject', workflow_id: workflow.id, subject_id: subject.id)
      action.perform
      expect(action.status).to eq('completed')
      expect(action.completed_at).to be_present
    end

    it 'marks the action as failed if it raises an error' do
      allow_any_instance_of(Effects::RetireSubject).to receive(:perform).and_raise("Fake exception")

      action = SubjectAction.new(effect_type: 'retire_subject', workflow_id: workflow.id, subject_id: subject.id)

      expect { action.perform }.to raise_error("Fake exception")
      expect(action.status).to eq('failed')
    end
  end
end
