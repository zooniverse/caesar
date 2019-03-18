require 'rails_helper'

RSpec.describe UserReductionPolicy do
  subject { described_class }
  let(:not_logged_in_credential){ fake_credential logged_in: false }
  let(:expired_credential){ fake_credential expired: true }
  let(:admin_credential){ fake_credential admin: true }

  permissions ".scope" do
    let!(:reductions) { create_list :user_reduction, 4 }

    it 'allows any authenticated user to get their own reductions' do
      credential = fake_credential logged_in: true, user_id: 55555
      reduction2 = create :user_reduction, user_id: 55555

      expect(records_for(credential)).to match_array([reduction2])
    end

    it 'returns no records when not logged in' do
      expect(records_for(not_logged_in_credential)).to match_array(UserReduction.none)
    end

    it 'returns all records for an admin' do
      expect(records_for(admin_credential)).to match_array(UserReduction.all)
    end

    it 'returns no records when not a collaborator on any project' do
      credential = fake_credential project_ids: []
      expect(records_for(credential)).to match_array(UserReduction.none)
    end

    it 'returns records that the subject is a collaborator on' do
      workflow = create(:workflow)
      credential = fake_credential project_ids: [workflow.project_id]
      expect(records_for(credential)).to match_array(UserReduction.all)
    end
  end

  permissions :show? do
    let(:reduction) { create :user_reduction }

    it 'denies access when not logged in' do
      expect(subject).not_to permit(not_logged_in_credential, reduction)
    end

    it 'denies access when not a collaborator on the project' do
      credential = fake_credential project_ids: []
      expect(subject).not_to permit(credential, reduction)
    end

    it 'grants access to an admin' do
      expect(subject).to permit(admin_credential, reduction)
    end

    it 'grants access to reductions of collaborated project' do
      credential = fake_credential project_ids: [reduction.reducible.project_id]
      expect(subject).to permit(credential, reduction)
    end

    it 'grants access if the workflow has public reductions' do
      reduction.reducible.update! public_reductions: true
      expect(subject).to permit(not_logged_in_credential, reduction)
    end

    it 'returns both public and scoped reductions' do
      public_reduction = create(:user_reduction)
      public_reduction.reducible.update! public_reductions: true
      credential = fake_credential project_ids: [reduction.reducible.project_id]
      expect(subject).to permit(credential, reduction)
      expect(subject).to permit(credential, public_reduction)
    end

    it 'returns project-scoped reductions' do
      project = create(:project)
      project_reduction = create(:user_reduction, reducible: project)
      credential = fake_credential project_ids: [project_reduction.reducible.id]
      expect(subject).to permit(credential, project_reduction)
    end
  end

  permissions :update? do
    let(:reduction) { create :user_reduction }

    it 'grants access to an admin' do
      expect(subject).to permit(admin_credential, reduction)
    end

    it 'grants access to reduction of collaborated project' do
      credential = fake_credential project_ids: [reduction.reducible.project_id]
      expect(subject).to permit(credential, reduction)
    end

    it 'denies access to non-collabs for public reduction' do
      reduction.reducible.update! public_reductions: true
      credential = fake_credential logged_in: true
      expect(subject).not_to permit(credential, reduction)
    end
  end

  permissions :destroy? do
    it 'allows admin to destroy records' do
      reduction = create :user_reduction
      expect(subject).to permit(admin_credential, reduction)
    end
  end
end
