require 'spec_helper'

describe ReducersController, :type => :controller do
  before { fake_session admin: true }

  let(:workflow) { create :workflow }

  let(:reducer) do
    create :external_reducer, workflow: workflow
  end

  describe '#index' do
    it 'lists reducers for a workflow' do
      reducers = [create(:external_reducer, reducible: workflow),
                  create(:stats_reducer, reducible: workflow)]
      get :index, params: {workflow_id: workflow.id}, format: :json
      json_response = JSON.parse(response.body)
      expect(json_response.map { |i| i["id"] }).to match_array(reducers.map(&:id))
    end

    it 'returns empty list when there are no reducers' do
      get :index, params: {reducible_id: workflow.id}, format: :json
      json_response = JSON.parse(response.body)
      expect(json_response).to eq([])
    end
  end

  describe '#show' do
    it 'returns a reducer' do
      get :show, params: {workflow_id: workflow.id, id: reducer.id}, format: :json
      expect(response.body).to eq(reducer.to_json)
    end
  end

  describe '#new' do
    it 'renders when given a type' do
      get :new, params: {workflow_id: workflow.id, type: 'external'}
      expect(response.status).to eq(200)
    end
  end

  describe '#edit' do
    it 'renders' do
      get :edit, params: {workflow_id: workflow.id, id: reducer.id}
      expect(response.status).to eq(200)
    end
  end

  describe '#create' do
    let(:reducer_params) { {key: 'a', type: 'external', url: 'https://example.org'} }

    it 'creates a new reducer' do
      post :create, params: {workflow_id: workflow.id, reducer: reducer_params}
      expect(response).to redirect_to(workflow_path(workflow))
      expect(workflow.reducers.count).to eq(1)
      expect(workflow.reducers.first.url).to eq('https://example.org')
    end

    it 'renders form on errors' do
      post :create, params: {workflow_id: workflow.id, reducer: {key: nil, type: 'external'}}
      expect(response.status).to eq(200)
    end
  end

  describe '#update' do
    it 'updates the specified reducer' do
      put :update, params: {workflow_id: workflow.id,
                            id: reducer.id,
                            reducer: {url: 'https://example.org/2'}}
      expect(response).to redirect_to(workflow_path(workflow))
      expect(workflow.reducers.first.url).to eq('https://example.org/2')
    end

    it 'renders form on errors' do
      put :update, params: {workflow_id: workflow.id,
                            id: reducer.id,
                            reducer: {key: nil, type: 'external'}}
      expect(response.status).to eq(200)
    end
  end
end
