require 'rails_helper'

describe SubjectRuleEffectPolicy do
  subject { described_class }
  let(:not_logged_in_credential){ fake_credential logged_in: false }
  let(:expired_credential){ fake_credential expired: true }
  let(:admin_credential){ fake_credential admin: true }

  let(:workflow) { create :workflow }
  let(:rule) { create :subject_rule, workflow: workflow }
  let(:effect) do
    create(
      :subject_rule_effect,
      action: 'retire_subject',
      config: { foo: 'bar' },
      subject_rule: rule
    )
  end

  before { effect }

  permissions ".scope" do
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

  permissions :create?, :update? do
    let(:workflow) { create :workflow }

    it 'denies access when not logged in' do
      expect(subject).not_to permit(not_logged_in_credential, effect)
    end

    it 'denies access when token has expired' do
      expect(subject).not_to permit(expired_credential, effect)
    end

    # temp fix for to stop non-admin users modify the rule effects
    it 'denies access to all user that are collaborators on the project' do
      credential = fake_credential(project_ids: [workflow.project_id])
      expect(subject).not_to permit(credential, effect)
    end

    it 'grants access to an admin' do
      expect(subject).to permit(admin_credential, effect)
    end
  end

  permissions :index?, :edit?, :destroy? do
    it 'denies access to non-collaborators on the project' do
      credential = fake_credential(project_ids: [workflow.project_id+1])
      expect(subject).not_to permit(credential, effect)
    end

    it 'grants access to project owner' do
      credential = fake_credential project_ids: [workflow.project_id]
      expect(subject).to permit(credential, effect)
    end

    it "grants access to admins" do
      expect(subject).to permit(admin_credential, effect)
    end
  end
end
