require 'spec_helper'

describe ExtractorsController, :type => :controller do

  let(:workflow) { create :workflow }

  let(:extractor) do
    create :external_extractor, workflow: workflow
  end

  context 'as a permissioned user' do
    before{ fake_session admin: false, project_ids: [workflow.project_id], logged_in: true }

    describe '#destroy' do
      it 'lets a user delete extractors if they own the workflow' do
        e2 = create :external_extractor, workflow: workflow
        response = delete :destroy, params: { id: e2.id, workflow_id: workflow.id }, format: :json

        expect(Extractor.find_by_id(e2.id)).to be(nil)
        expect(response.status).to eq(204)
      end

      it 'does not let a user delete extractors if they do not own the workflow' do
        other_workflow = create :workflow, project_id: workflow.project_id + 1
        e2 = create :external_extractor, workflow: other_workflow
        response = delete :destroy, params: { id: e2.id, workflow_id: workflow.id }, format: :json

        expect(Extractor.find_by_id(e2.id)).not_to be(nil)
        expect(response.status).to eq(404)
      end
    end
  end

  context 'as an admin' do
    before { fake_session admin: true }

    describe '#index' do
      it 'lists extractors for a workflow' do
        extractors = [create(:external_extractor, workflow: workflow),
                      create(:survey_extractor, workflow: workflow)]
        get :index, params: {workflow_id: workflow.id}, format: :json
        expect(json_response.map { |i| i["id"] }).to match_array(extractors.map(&:id))
      end

      it 'returns empty list when there are no extractors' do
        get :index, params: {workflow_id: workflow.id}, format: :json
        expect(json_response).to eq([])
      end
    end

    describe '#show' do
      it 'returns a extractor' do
        get :show, params: {workflow_id: workflow.id, id: extractor.id}, format: :json
        expect(response.body).to eq(extractor.to_json)
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
        get :edit, params: {workflow_id: workflow.id, id: extractor.id}
        expect(response.status).to eq(200)
      end
    end

    describe '#create' do
      let(:extractor_params) { {key: 'a', type: 'external', url: 'https://example.org'} }

      it 'creates a new extractor' do
        post :create, params: {workflow_id: workflow.id, extractor: extractor_params}
        expect(response).to redirect_to(workflow_path(workflow, anchor: 'extractors'))
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
        expect(response).to redirect_to(workflow_path(workflow, anchor: 'extractors'))
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
end
