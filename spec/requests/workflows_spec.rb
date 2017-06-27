require 'rails_helper'

RSpec.describe WorkflowsController, type: :controller do
  before { fake_session admin: true }

  describe "GET #show" do
    it "returns http success" do
      workflow = Workflow.create! project_id: 1
      get :show, format: :json, params: {id: workflow.id}
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PUT #update' do
    it 'creates a new workflow' do
      put :update, as: :json,
          params: {id: 123},
          body: {
            workflow: {
              project_id: 1,
              extractors_config: {"type" => "external"}
            }
          }.to_json

      expect(response).to have_http_status(:success)
      expect(Workflow.count).to eq(1)
    end

    it 'updates an existing workflow' do
      workflow = Workflow.create!(project_id: 1)

      put :update, as: :json,
          params: {id: workflow.id},
          body: {
            workflow: {
              extractors_config: {"type" => "external"}
            }
          }.to_json

      expect(response).to have_http_status(:success)
      expect(workflow.reload.extractors_config).to eq("type" => "external")
    end
  end
end
