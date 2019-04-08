require 'rails_helper'

RSpec.describe DataRequestPolicy do
  subject { described_class }

  let(:workflow) { build :workflow }

  permissions ".scope" do
    let!(:data_requests) { create_list :data_request, 4 }

    it 'returns no records when not logged in' do
      credential = fake_credential logged_in: false
      expect(records_for(credential)).to match_array(DataRequest.none)
    end

    it 'returns all records for an admin' do
      credential = fake_credential admin: true, project_ids: []
      expect(records_for(credential)).to match_array(DataRequest.all)
    end

    it 'returns no records when not a collaborator on any project' do
      credential = fake_credential project_ids: []
      expect(records_for(credential)).to match_array(DataRequest.none)
    end

    it 'returns records that the user is a collaborator on' do
      p1 = create :project
      p2 = create :project
      p3 = create :project

      r1 = create :data_request, exportable: p1
      r2 = create :data_request, exportable: p2
      r3 = create :data_request, exportable: p2
      create :data_request, exportable: p3

      credential = fake_credential project_ids: [p1.id, p2.id]
      expect(records_for(credential)).to match_array([r1, r2, r3])
    end
  end

  permissions :show? do
    let(:data_request) { create :data_request }

    it 'denies access when not logged in' do
      credential = fake_credential logged_in: false
      expect(subject).not_to permit(credential, data_request)
    end

    it 'denies access when token has expired' do
      credential = fake_credential expired: true, project_ids: [data_request.exportable.project_id]
      expect(subject).not_to permit(credential, data_request)
    end

    it 'denies access when not a collaborator on the project' do
      credential = fake_credential project_ids: []
      expect(subject).not_to permit(credential, data_request)
    end

    it 'grants access to an admin' do
      credential = fake_credential admin: true, project_ids: []
      expect(subject).to permit(credential, data_request)
    end

    it 'grants access to data_requests of collaborated project' do
      credential = fake_credential project_ids: [data_request.exportable.project_id]
      expect(subject).to permit(credential, data_request)
    end
  end

  permissions :create? do
    let(:data_request) { create :data_request }

    it 'grants access to an admin' do
      credential = fake_credential admin: true, project_ids: []
      expect(subject).to permit(credential, data_request)
    end

    it 'grants access to data_requests of collaborated project' do
      credential = fake_credential project_ids: [data_request.exportable.project_id]
      expect(subject).to permit(credential, data_request)
    end

    it 'grants access to data_requests of a workflow with public extracts' do
      workflow.update! public_extracts: true
      data_request = build(:data_request, exportable: workflow, requested_data: 'extracts')
      credential = fake_credential project_ids: []
      expect(subject).to permit(credential, data_request)
    end

    it 'grants access to data_requests of a workflow with public reductions' do
      workflow.update! public_reductions: true
      data_request = build(:data_request, exportable: workflow, requested_data: 'subject_reductions')
      credential = fake_credential project_ids: []
      expect(subject).to permit(credential, data_request)
    end

    it 'does not let non-collaborators create requests for non-public workflows', :aggregate_failures do
      workflow = build(:workflow, public_extracts: true) # <- Note extracts are public, but request reductions
      data_request = build(:data_request, exportable: workflow, requested_data: 'subject_reductions')
      credential = fake_credential project_ids: []
      expect(subject).not_to permit(credential, data_request)

      workflow = build(:workflow, public_reductions: true) # <- Note reductions are public, but request extracts
      data_request = build(:data_request, exportable: workflow, requested_data: 'extracts')
      credential = fake_credential project_ids: []
      expect(subject).not_to permit(credential, data_request)
    end
  end

  permissions :update? do
    let(:data_request) { create :data_request }

    it 'grants access to an admin' do
      credential = fake_credential admin: true, project_ids: []
      expect(subject).to permit(credential, data_request)
    end

    it 'grants access to data_requests of collaborated project' do
      credential = fake_credential project_ids: [data_request.exportable.project_id]
      expect(subject).to permit(credential, data_request)
    end

    it 'does not let non-collaborators update public data requests' do
      workflow.update! public_extracts: true
      data_request = build(:data_request, exportable: workflow, public: true)
      credential = fake_credential project_ids: []
      expect(subject).not_to permit(credential, data_request)
    end
  end

  permissions :destroy? do
    it 'allows admin to destroy records' do
      data_request = create :data_request
      credential = fake_credential admin: true
      expect(subject).to permit(credential, data_request)
    end
  end
end
