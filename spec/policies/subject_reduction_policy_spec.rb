require 'rails_helper'

RSpec.describe SubjectReductionPolicy do
  subject { described_class }

  permissions ".scope" do
    let!(:reductions) { create_list :subject_reduction, 4 }

    it 'returns no records when not logged in' do
      credential = build(:credential, :not_logged_in)
      expect(records_for(credential)).to match_array(SubjectReduction.none)
    end

    it 'returns all records for an admin' do
      credential = build(:credential, :admin, project_ids: [])
      expect(records_for(credential)).to match_array(SubjectReduction.all)
    end

    it 'returns no records when not a collaborator on any project' do
      credential = build(:credential, project_ids: [])
      expect(records_for(credential)).to match_array(SubjectReduction.none)
    end

    it 'returns records that the user is a collaborator on' do
      credential = build(:credential, project_ids: [])
      expect(records_for(credential)).to match_array(SubjectReduction.none)
    end
  end

  permissions :show? do
    let(:reduction) { create :subject_reduction }

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
      public_reduction = create(:subject_reduction)
      public_reduction.reducible.update! public_reductions: true
      credential = build(:credential, workflows: [reduction.reducible])
      expect(subject).to permit(credential, reduction)
      expect(subject).to permit(credential, public_reduction)
    end

    it 'returns project-scoped reductions' do
      project = create(:project)
      public_reduction = create(:subject_reduction, reducible: project)
      public_reduction.reducible.update! public_reductions: true
      credential = build(:credential, workflows: [reduction.reducible])
      expect(subject).to permit(credential, reduction)
      expect(subject).to permit(credential, public_reduction)
    end

  end

  permissions :update? do
    let(:reduction) { create :subject_reduction }

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
      reduction = create :subject_reduction
      credential = build(:credential, :admin)
      expect(subject).to permit(credential, reduction)
    end
  end
end
