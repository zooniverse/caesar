require 'rails_helper'

RSpec.describe Workflow, type: :model do
  let(:workflow) { create :workflow }
  let(:subject) { create :subject }

  describe 'public_data?' do
    describe 'public extracts' do
      it 'is true' do
        workflow.public_extracts = true
        expect(workflow.public_data?("extracts")).to be_truthy
      end

      it 'is false' do
        workflow.public_extracts = false
        expect(workflow.public_data?("extracts")).to be_falsey
      end
    end

    describe 'public reductions' do
      it 'is true' do
        workflow.public_reductions = true
        expect(workflow.public_data?("reductions")).to be_truthy
      end

      it 'is false' do
        workflow.public_reductions = false
        expect(workflow.public_data?("reductions")).to be_falsey
      end
    end

    it 'is false for any other data type' do
      expect(workflow.public_data?("foobar")).to be_falsey
    end
  end

  describe 'cached counters' do
    it 'increments the extract count when new extracts are added' do
      Extract.create! workflow_id: workflow.id, subject_id: subject.id, classification_id: 12345, classification_at: DateTime.now, extractor_key: 'key'
      expect(Workflow.find(workflow.id).extracts_count).to eq(1)
      Extract.create! workflow_id: workflow.id, subject_id: subject.id, classification_id: 12346, classification_at: DateTime.now, extractor_key: 'key'
      expect(Workflow.find(workflow.id).extracts_count).to eq(2)
    end

    it 'increments the subject reduction count when new reductions are added' do
      SubjectReduction.create! reducible: workflow, subject_id: subject.id, reducer_key: 'key'
      expect(Workflow.find(workflow.id).subject_reductions_count).to eq(1)
    end

    it 'increments the user reduction count when new reductions are added' do
      UserReduction.create! reducible: workflow, user_id: 12345, reducer_key: 'key'
      expect(Workflow.find(workflow.id).user_reductions_count).to eq(1)
    end

    it 'increments the subject action count when new actions are added' do
      SubjectAction.create! workflow_id: workflow.id, subject_id: subject.id, effect_type: 'retire_subject'
      expect(Workflow.find(workflow.id).subject_actions_count).to eq(1)
    end

    it 'increments the user action count when new actions are added' do
      UserAction.create! workflow_id: workflow.id, user_id: 12345, effect_type: 'promote_user'
      expect(Workflow.find(workflow.id).user_actions_count).to eq(1)
    end
  end
end
