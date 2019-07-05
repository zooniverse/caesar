require 'spec_helper'

RSpec.describe SessionsController, type: :controller do
  describe "GET /session" do
    it "returns http success" do
      fake_session expired: false, admin: false
      get :show
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /session" do
    it "returns http success" do
      fake_session expired: false, admin: false
      post :show
      expect(response).to have_http_status(:success)
    end
  end

  describe "DELETE /session" do
    before { fake_session admin: true }

    it "returns http success" do
      delete :destroy
      expect(response).to redirect_to("/session")
    end
  end

end
