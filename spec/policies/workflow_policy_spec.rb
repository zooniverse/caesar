require 'rails_helper'

describe WorkflowPolicy do
  subject { described_class }
  let(:not_logged_in_credential){ fake_credential logged_in: false }
  let(:expired_credential){ fake_credential expired: true }
  let(:admin_credential){ fake_credential admin: true }

  permissions ".scope" do
    let!(:workflows) do
      create_list(:workflow, 4)
    end

    it 'returns no records when not logged in' do
      expect(records_for(not_logged_in_credential)).to eq(Workflow.none)
    end

    it 'returns no records when token has expired' do
      expect(records_for(expired_credential)).to eq(Workflow.none)
    end

    it 'returns all workflows for an admin' do
      expect(records_for(admin_credential)).to eq(Workflow.all)
    end

    it 'returns no workflows when not a collaborator on any project' do
      credential = fake_credential project_ids: []
      expect(records_for(credential)).to eq(Workflow.none)
    end

    it 'returns workflows that the user is a collaborator on' do
      credential = fake_credential(project_ids: workflows.pluck(:project_id).uniq)
      expect(records_for(credential)).to match_array(Workflow.all)
    end
  end

  permissions :show?, :create?, :update? do
    let(:workflow) { create :workflow }

    it 'denies access when not logged in' do
      expect(subject).not_to permit(not_logged_in_credential, workflow)
    end

    it 'denies access when token has expired' do
      expect(subject).not_to permit(expired_credential, workflow)
    end

    it 'denies access when not a collaborator on the project' do
      credential = fake_credential project_ids: []
      expect(subject).not_to permit(credential, workflow)
    end

    it 'grants access to an admin' do
      expect(subject).to permit(admin_credential, workflow)
    end

    it 'grants access to workflows of collaborated project' do
      credential = fake_credential project_ids: [workflow.project_id]
      expect(subject).to permit(credential, workflow)
    end
  end

  permissions :destroy? do
    it 'denies access to project owner' do
      workflow = build(:workflow)
      credential = fake_credential project_ids: [workflow.project_id]
      expect(subject).not_to permit(credential, workflow)
    end

    it "grants access to admins" do
      workflow = build(:workflow)
      expect(subject).to permit(admin_credential, workflow)
    end
  end
end
