require 'rails_helper'

RSpec.describe WorkflowsController, type: :controller do
  before { fake_session admin: true }

  describe "GET #show" do
    it "returns http success" do
      workflow = create(:workflow)
      get :show, format: :json, params: {id: workflow.id}
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #new' do
    before do
      allow(@credential).to receive(:accessible_workflow?).and_return(false)
    end

    context 'for a project the user has access to' do
      it 'renders a form' do
        workflow_hash = {"id" => '123', "links" => {"project" => "10"}}
        allow(@credential).to receive(:accessible_workflow?)
                                .with(workflow_hash["id"])
                                .and_return(workflow_hash)

        get :new, params: {id: workflow_hash["id"]}
        expect(response).to have_http_status(:ok)
      end

      it 'redirects to the workflow if it already exists' do
        workflow = create(:workflow)
        get :new, params: {id: workflow.id}
        expect(response).to redirect_to(action: :show, id: workflow.id)
      end
    end

    context 'for a project the user does not have access to' do
      it 'returns 403' do
        workflow_hash = {"id" => '123', "links" => {"project" => "10"}}
        allow(@credential).to receive(:project_ids).and_return([])
        allow(@credential).to receive(:accessible_workflow?)
                                .with(workflow_hash["id"])
                                .and_return(nil)

        get :new, params: {id: workflow_hash["id"]}
        expect(response).to have_http_status(:not_found)
      end
    end

    it 'returns error if a workflow id is not given' do
      get :new
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'POST #create' do
    context "the user has access to the workflow" do
      let(:workflow_hash) { {"id" => '123', "links" => {"project" => "10"}} }
      before do
        allow(@credential).to receive(:project_ids)
                                .and_return([10])
        allow(@credential).to receive(:accessible_workflow?)
                                .with(workflow_hash["id"])
                                .and_return(workflow_hash)
      end

      it 'creates a workflow json' do
        post :create, params: {workflow: {id: workflow_hash["id"],
                                          project_id: workflow_hash["links"]["project_id"],
                                          public_reductions: true}}, format: :json

        expect(response.status).to eq(200)
        expect(Workflow.find(workflow_hash["id"])).to be_present
        expect(Workflow.find(workflow_hash["id"]).public_reductions).to be_truthy
      end

      it 'creates a workflow html' do
        post :create, params: {workflow: {id: workflow_hash["id"],
                                          project_id: workflow_hash["links"]["project_id"],
                                          public_reductions: true}}

        expect(response).to redirect_to(workflows_path)
        expect(Workflow.find(workflow_hash["id"])).to be_present
        expect(Workflow.find(workflow_hash["id"]).public_reductions).to be_truthy
      end

      it 'redirects with a 302 if the workflow already exists' do
        workflow = create(:workflow, id: workflow_hash["id"])
        post :create, params: {workflow: {id: workflow_hash["id"],
                                          project_id: workflow_hash["links"]["project_id"],
                                          public_reductions: true}}

        expect(response).to redirect_to workflow
        expect(response.status).to eq(302)
        expect(flash[:alert]).to be_present
      end
    end

    context "the user does not have access to the project" do
      it 'returns 403 for a project the user does not have access to' do
        workflow_hash = {"id" => '123', "links" => {"project" => "10"}}
        allow(@credential).to receive(:project_ids).and_return([])
        allow(@credential).to receive(:accessible_workflow?).with(workflow_hash["id"]).and_return(nil)

        post :create, params: {workflow: {id: workflow_hash["id"], project_id: workflow_hash["links"]["project_id"]}, format: :json}
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'PUT #update' do
    it 'updates an existing workflow' do
      workflow = create(:workflow)

      put :update, as: :json,
          params: {id: workflow.id},
          body: {
            workflow: {
              extractors_config: {"ext" => {"type" => "external"}}
            }
          }.to_json

      expect(response).to have_http_status(:success)
      expect(workflow.reload.extractors[0]).to be_present
    end

    describe 'rerunning' do
      let(:workflow) { create(:workflow) }
      before { allow(controller).to receive(:workflow).and_return(workflow) }

      it 'calls rerun_extractors on the workflow' do
        expect(workflow).to receive(:rerun_extractors).once
        put :update, params: {id: workflow.id, workflow: {rerun: 'extractors'}}
      end

      it 'calls rerun_reducers on the workflow' do
        expect(workflow).to receive(:rerun_reducers).once
        put :update, params: {id: workflow.id, workflow: {rerun: 'reducers'}}
      end
    end
  end

end
