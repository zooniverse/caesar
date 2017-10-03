require 'spec_helper'

describe ExtractorsController, :type => :controller do
  before { fake_session admin: true }

  let(:workflow) { create :workflow }

  let(:extractor) do
    create :external_extractor, workflow: workflow
  end

  describe '#new' do
    it 'renders when given a type' do
      get :new, params: {workflow_id: workflow.id, type: 'external'}
      expect(response.status).to eq(200)
    end
  end

  describe '#edit' do
    it 'renders' do
      get :edit, params: {workflow_id: workflow.id, id: extractor.id}
      expect(response.status).to eq(200)
    end
  end

  describe '#create' do
    let(:extractor_params) { {key: 'a', type: 'external', url: 'https://example.org'} }

    it 'creates a new extractor' do
      post :create, params: {workflow_id: workflow.id, extractor: extractor_params}
      expect(response).to redirect_to(workflow_path(workflow))
      expect(workflow.extractors.count).to eq(1)
      expect(workflow.extractors.first.url).to eq('https://example.org')
    end

    it 'renders form on errors' do
      post :create, params: {workflow_id: workflow.id, extractor: {key: nil, type: 'external'}}
      expect(response.status).to eq(200)
    end
  end

  describe '#update' do
    it 'updates the specified extractor' do
      put :update, params: {workflow_id: workflow.id,
                            id: extractor.id,
                            extractor: {url: 'https://example.org/2'}}
      expect(response).to redirect_to(workflow_path(workflow))
      expect(workflow.extractors.first.url).to eq('https://example.org/2')
    end

    it 'renders form on errors' do
      put :update, params: {workflow_id: workflow.id,
                            id: extractor.id,
                            extractor: {key: nil, type: 'external'}}
      expect(response.status).to eq(200)
    end
  end
end
