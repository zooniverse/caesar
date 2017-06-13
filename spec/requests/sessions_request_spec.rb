require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /session" do
    pending
  end

  describe "DELETE /session" do
    before { fake_session admin: true }

    it "returns http success" do
      delete :destroy
      expect(response).to redirect_to("/session/new")
    end
  end

end
