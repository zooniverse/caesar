require 'rails_helper'

RSpec.describe DataRequestPolicy do
  subject { described_class }

  let(:workflow) { build :workflow }

  permissions ".scope" do
    let!(:data_requests) { create_list :data_request, 4 }

    it 'returns no records when not logged in' do
      credential = build(:credential, :not_logged_in)
      expect(records_for(credential)).to match_array(DataRequest.none)
    end

    it 'returns all records for an admin' do
      credential = build(:credential, :admin, project_ids: [])
      expect(records_for(credential)).to match_array(DataRequest.all)
    end

    it 'returns no records when not a collaborator on any project' do
      credential = build(:credential, project_ids: [])
      expect(records_for(credential)).to match_array(DataRequest.none)
    end

    it 'returns records that the user is a collaborator on' do
      credential = build(:credential, project_ids: [])
      expect(records_for(credential)).to match_array(DataRequest.none)
    end
  end

  permissions :show? do
    let(:data_request) { create :data_request }

    it 'denies access when not logged in' do
      credential = build(:credential, :not_logged_in)
      expect(subject).not_to permit(credential, data_request)
    end

    it 'denies access when token has expired' do
      credential = build(:credential, :expired, workflows: [data_request.exportable])
      expect(subject).not_to permit(credential, data_request)
    end

    it 'denies access when not a collaborator on the project' do
      credential = build(:credential, workflows: [])
      expect(subject).not_to permit(credential, data_request)
    end

    it 'grants access to an admin' do
      credential = build(:credential, :admin, workflows: [])
      expect(subject).to permit(credential, data_request)
    end

    it 'grants access to data_requests of collaborated project' do
      credential = build(:credential, workflows: [data_request.exportable])
      expect(subject).to permit(credential, data_request)
    end
  end

  permissions :create? do
    let(:data_request) { create :data_request }

    it 'grants access to an admin' do
      credential = build(:credential, :admin, workflows: [])
      expect(subject).to permit(credential, data_request)
    end

    it 'grants access to data_requests of collaborated project' do
      credential = build(:credential, workflows: [data_request.exportable])
      expect(subject).to permit(credential, data_request)
    end

    it 'grants access to data_requests of a workflow with public extracts' do
      workflow.update! public_extracts: true
      data_request = build(:data_request, exportable: workflow, requested_data: 'extracts')
      credential = build(:credential, workflows: [])
      expect(subject).to permit(credential, data_request)
    end

    it 'grants access to data_requests of a workflow with public extracts' do
      workflow.update! public_reductions: true
      data_request = build(:data_request, exportable: workflow, requested_data: 'reductions')
      credential = build(:credential, workflows: [])
      expect(subject).to permit(credential, data_request)
    end

    it 'does not let non-collaborators create requests for non-public workflows', :aggregate_failures do
      workflow = build(:workflow, public_extracts: true) # <- Note extracts are public, but request reductions
      data_request = build(:data_request, exportable: workflow, requested_data: 'reductions')
      credential = build(:credential, workflows: [])
      expect(subject).not_to permit(credential, data_request)

      workflow = build(:workflow, public_reductions: true) # <- Note reductions are public, but request extracts
      data_request = build(:data_request, exportable: workflow, requested_data: 'extracts')
      credential = build(:credential, workflows: [])
      expect(subject).not_to permit(credential, data_request)
    end
  end

  permissions :update? do
    let(:data_request) { create :data_request }

    it 'grants access to an admin' do
      credential = build(:credential, :admin, workflows: [])
      expect(subject).to permit(credential, data_request)
    end

    it 'grants access to data_requests of collaborated project' do
      credential = build(:credential, workflows: [data_request.exportable])
      expect(subject).to permit(credential, data_request)
    end

    it 'does not let non-collaborators update public data requests' do
      workflow.update! public_extracts: true
      data_request = build(:data_request, exportable: workflow, public: true)
      credential = build(:credential, workflows: [])
      expect(subject).not_to permit(credential, data_request)
    end
  end

  permissions :destroy? do
    it 'allows admin to destroy records' do
      data_request = create :data_request
      credential = build(:credential, :admin)
      expect(subject).to permit(credential, data_request)
    end
  end
end
