require 'rails_helper'

RSpec.describe ReductionPolicy do
  subject { described_class }

  permissions ".scope" do
    let!(:reductions) { create_list :reduction, 4 }

    it 'returns no records when not logged in' do
      credential = build(:credential, :not_logged_in)
      expect(records_for(credential)).to match_array(Reduction.none)
    end

    it 'returns all records for an admin' do
      credential = build(:credential, :admin, project_ids: [])
      expect(records_for(credential)).to match_array(Reduction.all)
    end

    it 'returns no records when not a collaborator on any project' do
      credential = build(:credential, project_ids: [])
      expect(records_for(credential)).to match_array(Reduction.none)
    end

    it 'returns records that the user is a collaborator on' do
      credential = build(:credential, project_ids: [])
      expect(records_for(credential)).to match_array(Reduction.none)
    end
  end

  permissions :show? do
    let(:reduction) { create :reduction }

    it 'denies access when not logged in' do
      credential = build(:credential, :not_logged_in)
      expect(subject).not_to permit(credential, reduction)
    end

    it 'denies access when token has expired' do
      credential = build(:credential, :expired, workflows: [reduction.workflow])
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
      credential = build(:credential, workflows: [reduction.workflow])
      expect(subject).to permit(credential, reduction)
    end

    it 'grants access if the workflow has public reductions' do
      reduction.workflow.update! public_reductions: true
      credential = build(:credential, :not_logged_in)
      expect(subject).to permit(credential, reduction)
    end

  end

  permissions :create? do
    pending "add some examples to (or delete) #{__FILE__}"
  end

  permissions :update? do
    pending "add some examples to (or delete) #{__FILE__}"
  end

  permissions :destroy? do
    pending "add some examples to (or delete) #{__FILE__}"
  end
end
