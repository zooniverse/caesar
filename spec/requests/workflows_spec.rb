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

  describe 'PUT #update' do
    it 'updates an existing workflow' do
      workflow = create(:workflow)

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
