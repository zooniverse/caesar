require 'rails_helper'

RSpec.describe SubjectsController, type: :controller do
  before { fake_session admin: true }

  describe "GET #show" do
    it "returns http success" do
      workflow = create(:workflow)
      subject = create :subject

      get :show, params: {workflow_id: workflow.id, id: subject.id}
      expect(response).to have_http_status(:success)
    end
  end
end
