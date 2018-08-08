require 'rails_helper'

RSpec.describe UserReductionPolicy do
  subject { described_class }

  permissions ".scope" do
    let!(:reductions) { create_list :user_reduction, 4 }

    it 'returns no records when not logged in' do
      credential = build(:credential, :not_logged_in)
      expect(records_for(credential)).to match_array(UserReduction.none)
    end

    it 'returns all records for an admin' do
      credential = build(:credential, :admin, project_ids: [])
      expect(records_for(credential)).to match_array(UserReduction.all)
    end

    it 'returns no records when not a collaborator on any project' do
      credential = build(:credential, project_ids: [])
      expect(records_for(credential)).to match_array(UserReduction.none)
    end

    it 'returns records that the subject is a collaborator on' do
      workflow = create(:workflow)
      credential = build(:credential, project_ids: [workflow.project_id])
      expect(records_for(credential)).to match_array(UserReduction.all)
    end
  end

  permissions :show? do
    let(:reduction) { create :user_reduction }

    it 'denies access when not logged in' do
      credential = build(:credential, :not_logged_in)
      expect(subject).not_to permit(credential, reduction)
    end

    it 'denies access when token has expired' do
      credential = build(:credential, :expired, workflows: [reduction.reducible])
      expect(subject).not_to permit(credential, reduction)
    end

    it 'denies access when not a collaborator on the project' do
      credential = build(:credential, workflows: [])
      expect(subject).not_to permit(credential, reduction)
    end

    it 'grants access to an admin' do
      credential = build(:credential, :admin, workflows: [])
      expect(subject).to permit(credential, reduction)
    end

    it 'grants access to reductions of collaborated project' do
      credential = build(:credential, workflows: [reduction.reducible])
      expect(subject).to permit(credential, reduction)
    end

    it 'grants access if the workflow has public reductions' do
      reduction.reducible.update! public_reductions: true
      credential = build(:credential, :not_logged_in)
      expect(subject).to permit(credential, reduction)
    end

    it 'returns both public and scoped reductions' do
      public_reduction = create(:user_reduction)
      public_reduction.reducible.update! public_reductions: true
      credential = build(:credential, workflows: [reduction.reducible])
      expect(subject).to permit(credential, reduction)
      expect(subject).to permit(credential, public_reduction)
    end

    it 'returns project-scoped reductions' do
      project = create(:project)
      project_reduction = create(:user_reduction, reducible: project)
      credential = build(:credential, project_ids: [project_reduction.reducible.id])
      expect(subject).to permit(credential, project_reduction)
    end
  end

  permissions :update? do
    let(:reduction) { create :user_reduction }

    it 'grants access to an admin' do
      credential = build(:credential, :admin, workflows: [])
      expect(subject).to permit(credential, reduction)
    end

    it 'grants access to reduction of collaborated project' do
      credential = build(:credential, workflows: [reduction.reducible])
      expect(subject).to permit(credential, reduction)
    end

    it 'denies access to non-collabs for public reduction' do
      reduction.reducible.update! public_reductions: true
      credential = build(:credential)
      expect(subject).not_to permit(credential, reduction)
    end
  end

  permissions :destroy? do
    it 'allows admin to destroy records' do
      reduction = create :user_reduction
      credential = build(:credential, :admin)
      expect(subject).to permit(credential, reduction)
    end
  end
end
