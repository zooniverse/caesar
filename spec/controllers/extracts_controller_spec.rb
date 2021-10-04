# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExtractsController, type: :controller do
  before { fake_session admin: true }

  let(:extractor) { build(:external_extractor, key: 'ext') }
  let(:workflow) { create(:workflow, extractors: [extractor]) }

  describe 'GET #index' do
    it 'returns http success' do
      get :index, params: { workflow_id: workflow.id, extractor_key: extractor.key }
      expect(response).to have_http_status(:success)
    end
  end

  describe '#import' do
    let(:file_path) { 'https://example.org/file.csv' }
    it 'returns a 204 status' do
      post :import, params: { file: file_path, workflow_id: workflow.id }
      expect(response.status).to eq(204)
    end

    it 'queues an import worker' do
      allow(CreateExtractsWorker).to receive(:perform_async).with(file_path, workflow.id.to_s)
      post :import, params: { file: file_path, workflow_id: workflow.id }
      expect(CreateExtractsWorker).to have_received(:perform_async).with(file_path, workflow.id.to_s)
    end
  end
end
