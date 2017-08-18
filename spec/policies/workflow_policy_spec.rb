require 'rails_helper'

RSpec.describe WorkflowPolicy do
  subject { described_class }

  permissions ".scope" do
    let!(:workflows) do
      create_list(:workflow, 4)
    end

    it 'returns no records when not logged in' do
      credential = build(:credential, :not_logged_in)
      expect(records_for(credential)).to eq(Workflow.none)
    end

    it 'returns no records when token has expired' do
      credential = build(:credential, :expired, workflows: workflows)
      expect(records_for(credential)).to eq(Workflow.none)
    end

    it 'returns all workflows for an admin' do
      credential = build(:credential, :admin, project_ids: [])
      expect(records_for(credential)).to eq(Workflow.all)
    end

    it 'returns no workflows when not a collaborator on any project' do
      credential = build(:credential, project_ids: [])
      expect(records_for(credential)).to eq(Workflow.none)
    end

    it 'returns workflows that the user is a collaborator on' do
      credential = build(:credential, project_ids: [])
      expect(records_for(credential)).to eq(Workflow.none)
    end
  end

  permissions :show?, :create?, :update? do
    let(:workflow) { create :workflow }

    it 'denies access when not logged in' do
      credential = build(:credential, :not_logged_in)
      expect(subject).not_to permit(credential, workflow)
    end

    it 'denies access when token has expired' do
      credential = build(:credential, :expired, workflows: [workflow])
      expect(subject).not_to permit(credential, workflow)
    end

    it 'denies access when not a collaborator on the project' do
      credential = build(:credential, workflows: [])
      expect(subject).not_to permit(credential, workflow)
    end

    it 'grants access to an admin' do
      credential = build(:credential, :admin, workflows: [])
      expect(subject).to permit(credential, workflow)
    end

    it 'grants access to workflows of collaborated project' do
      credential = build(:credential, workflows: [workflow])
      expect(subject).to permit(credential, workflow)
    end
  end

  permissions :destroy? do
    it 'denies access to project owner' do
      workflow = build(:workflow)
      credential = build(:credential, workflows: [workflow])
      expect(subject).not_to permit(credential, workflow)
    end

    it "grants access to admins" do
      workflow = build(:workflow)
      credential = build(:credential, :admin)
      expect(subject).to permit(credential, workflow)
    end
  end
end
