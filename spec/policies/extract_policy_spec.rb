require 'rails_helper'

RSpec.describe ExtractPolicy do
  subject { described_class }

  permissions ".scope" do
    let!(:extracts) { create_list :extract, 4 }

    it 'returns no records when not logged in' do
      credential = build(:credential, :not_logged_in)
      expect(records_for(credential)).to match_array(Extract.none)
    end

    it 'returns all records for an admin' do
      credential = build(:credential, :admin, project_ids: [])
      expect(records_for(credential)).to match_array(Extract.all)
    end

    it 'returns no records when not a collaborator on any project' do
      credential = build(:credential, project_ids: [])
      expect(records_for(credential)).to match_array(Extract.none)
    end

    it 'returns records that the user is a collaborator on' do
      credential = build(:credential, project_ids: [])
      expect(records_for(credential)).to match_array(Extract.none)
    end
  end

  permissions :show? do
    let(:extract) { create :extract }

    it 'denies access when not logged in' do
      credential = build(:credential, :not_logged_in)
      expect(subject).not_to permit(credential, extract)
    end

    it 'denies access when token has expired' do
      credential = build(:credential, :expired, workflows: [extract.workflow])
      expect(subject).not_to permit(credential, extract)
    end

    it 'denies access when not a collaborator on the project' do
      credential = build(:credential, workflows: [])
      expect(subject).not_to permit(credential, extract)
    end

    it 'grants access to an admin' do
      credential = build(:credential, :admin, workflows: [])
      expect(subject).to permit(credential, extract)
    end

    it 'grants access to extracts of collaborated project' do
      credential = build(:credential, workflows: [extract.workflow])
      expect(subject).to permit(credential, extract)
    end

    it 'grants access if the workflow has public extracts' do
      extract.workflow.update! public_extracts: true
      credential = build(:credential, :not_logged_in)
      expect(subject).to permit(credential, extract)
    end
  end

  permissions :update? do
    let(:extract) { create :extract }

    it 'grants access to an admin' do
      credential = build(:credential, :admin, workflows: [])
      expect(subject).to permit(credential, extract)
    end

    it 'grants access to extracts of collaborated project' do
      credential = build(:credential, workflows: [extract.workflow])
      expect(subject).to permit(credential, extract)
    end

    it 'denies access to non-collabs for public extracts' do
      extract.workflow.update! public_extracts: true
      credential = build(:credential)
      expect(subject).not_to permit(credential, extract)
    end
  end

  permissions :destroy? do
    it 'allows admin to destroy records' do
      extract = create :extract
      credential = build(:credential, :admin)
      expect(subject).to permit(credential, extract)
    end
  end
end
