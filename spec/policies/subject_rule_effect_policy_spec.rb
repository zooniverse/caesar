# frozen_string_literal: true

require 'rails_helper'

describe SubjectRuleEffectPolicy do
  subject { described_class }
  let(:set_and_collection_project_id) { 76 }
  let(:subject_set) do
    {
      'id' => 777,
      'links' => { 'project' => set_and_collection_project_id }
    }
  end
  let(:collection) do
    {
      'id' => 333,
      'links' => { 'projects' => [set_and_collection_project_id] }
    }
  end
  let(:workflow) { create :workflow }
  let(:rule) { create :subject_rule, workflow: workflow }

  let(:basic_credential) { fake_credential }
  let(:not_logged_in_credential) { fake_credential logged_in: false }
  let(:expired_credential) { fake_credential expired: true }
  let(:admin_credential) { fake_credential admin: true }
  let(:workflow_owner_credential) { fake_credential(project_ids: [workflow.project_id]) }
  let(:set_and_collection_owner_credential) { fake_credential(project_ids: [set_and_collection_project_id, workflow.project_id]) }

  let(:effect) do
    create(
      :subject_rule_effect,
      action: 'retire_subject',
      config: { foo: 'bar' },
      subject_rule: rule
    )
  end
  let(:add_to_set_effect) do
    create(
      :subject_rule_effect,
      action: 'add_subject_to_set',
      config: { 'subject_set_id': subject_set['id'] },
      subject_rule: rule
    )
  end
  let(:add_to_collection_effect) do
    create(
      :subject_rule_effect,
      action: 'add_subject_to_collection',
      config: { 'collection_id': collection['id'] },
      subject_rule: rule
    )
  end

  let(:panoptes) do
    double('PanoptesAdapter',
           subject_set: subject_set,
           collection: collection)
  end

  before { effect }

  permissions '.scope' do
    it 'returns no records when not logged in' do
      expect(records_for(not_logged_in_credential)).to match_array(SubjectRuleEffect.none)
    end

    it 'returns no records when token has expired' do
      expect(records_for(expired_credential)).to match_array(SubjectRuleEffect.none)
    end

    it 'returns all workflow subject rule effects for an admin' do
      expect(records_for(admin_credential)).to match_array(SubjectRuleEffect.where(id: effect.id))
    end

    it 'returns no workflow subject rule effects when not a collaborator on any project' do
      credential = fake_credential project_ids: []
      expect(records_for(credential)).to match_array(SubjectRuleEffect.none)
    end

    it 'returns the workflow subject rule effects the user is a collaborator on' do
      credential = fake_credential(project_ids: [workflow.project_id])
      expect(records_for(credential)).to match_array(SubjectRuleEffect.where(id: effect.id))
    end
  end

  permissions :create? do
    it 'denies access when not logged in' do
      expect(subject).not_to permit(not_logged_in_credential, effect)
    end

    it 'denies access when token has expired' do
      expect(subject).not_to permit(expired_credential, effect)
    end

    it 'grants access to an admin' do
      expect(subject).to permit(admin_credential, effect)
    end

    context 'subject set and collection permissions' do
      before do
        allow(Effects).to receive(:panoptes).and_return(panoptes)
      end

      it 'grants access when effect\'s subject set belongs to project that user is owner of' do
        expect(subject).to permit(set_and_collection_owner_credential, add_to_set_effect)
      end

      it "denies access when effect's subject set belongs to project that user does not have access to" do
        expect(subject).not_to permit(workflow_owner_credential, add_to_set_effect)
      end

      it "grants access when effect's subject set belongs to project that user is owner of" do
        # subject set and collection share project id, subj set owner is also the collection owner
        expect(subject).to permit(set_and_collection_owner_credential, add_to_collection_effect)
      end

      it "denies access when effect's collection belongs to project that user does not have access to" do
        expect(subject).not_to permit(workflow_owner_credential, add_to_collection_effect)
      end
    end
  end

  permissions :create?, :update? do
    it 'denies access when not logged in' do
      expect(subject).not_to permit(not_logged_in_credential, effect)
    end

    it 'denies access when token has expired' do
      expect(subject).not_to permit(expired_credential, effect)
    end

    it 'grants access to an admin' do
      expect(subject).to permit(admin_credential, effect)
    end
  end

  permissions :edit?, :destroy? do
    it 'denies access to non-collaborators on the project' do
      credential = fake_credential(project_ids: [workflow.project_id + 1])
      expect(subject).not_to permit(credential, effect)
    end

    it 'grants access to project owner' do
      credential = fake_credential project_ids: [workflow.project_id]
      expect(subject).to permit(credential, effect)
    end

    it 'grants access to admins' do
      expect(subject).to permit(admin_credential, effect)
    end
  end

  permissions :index?, :show?, :new? do
    it 'denies access when not logged in' do
      expect(subject).not_to permit(not_logged_in_credential, workflow)
    end

    it 'denies access when token has expired' do
      expect(subject).not_to permit(expired_credential, workflow)
    end

    it 'grants access to an admin' do
      expect(subject).to permit(admin_credential, workflow)
    end

    it 'grants access when user has permission to the project associated with the workflow' do
      expect(subject).to permit(workflow_owner_credential, workflow)
    end

    it 'denies access when user does not have permission to the associated project' do
      expect(subject).not_to permit(basic_credential, workflow)
    end
  end
end
