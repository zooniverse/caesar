require 'rails_helper'

RSpec.describe ExtractPolicy do
  subject { described_class }
  let(:not_logged_in_credential){ fake_credential logged_in: false }
  let(:expired_credential){ fake_credential expired: true }
  let(:admin_credential){ fake_credential admin: true }

  permissions ".scope" do
    let!(:extracts) { create_list :extract, 4 }

    it 'returns no records when not logged in' do
      expect(records_for(not_logged_in_credential)).to match_array(Extract.none)
    end

    it 'returns all records for an admin' do
      expect(records_for(admin_credential)).to match_array(Extract.all)
    end

    it 'returns no records when not a collaborator on any project' do
      credential = fake_credential project_ids: []
      expect(records_for(credential)).to match_array(Extract.none)
    end

    it 'returns records that the user is a collaborator on' do
      #TODO: this test does not do what it says it does
      credential = fake_credential project_ids: []
      expect(records_for(credential)).to match_array(Extract.none)
    end
  end

  permissions :show? do
    let(:extract) { create :extract }

    it 'denies access when not logged in' do
      allow_any_instance_of(Panoptes::Client).to receive(:authenticated?).and_return(false)

      expect(subject).not_to permit(not_logged_in_credential, extract)
    end

    it 'denies access when not a collaborator on the project' do
      credential = fake_credential project_ids: []
      expect(subject).not_to permit(credential, extract)
    end

    it 'grants access to an admin' do
      expect(subject).to permit(admin_credential, extract)
    end

    it 'grants access to extracts of collaborated project' do
      credential = fake_credential project_ids: [extract.workflow.project_id]
      expect(subject).to permit(credential, extract)
    end

    it 'grants access if the workflow has public extracts' do
      extract.workflow.update! public_extracts: true
      expect(subject).to permit(not_logged_in_credential, extract)
    end
  end

  permissions :update? do
    let(:extract) { create :extract }

    it 'grants access to an admin' do
      expect(subject).to permit(admin_credential, extract)
    end

    it 'grants access to extracts of collaborated project' do
      credential = fake_credential project_ids: [extract.workflow.project_id]
      expect(subject).to permit(credential, extract)
    end

    it 'denies access to non-collabs for public extracts' do
      extract.workflow.update! public_extracts: true
      credential = fake_credential logged_in: true
      expect(subject).not_to permit(credential, extract)
    end
  end

  permissions :destroy? do
    it 'allows admin to destroy records' do
      extract = create :extract
      expect(subject).to permit(admin_credential, extract)
    end
  end
end
