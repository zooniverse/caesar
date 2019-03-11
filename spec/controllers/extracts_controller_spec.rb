require 'rails_helper'

RSpec.describe ExtractsController, type: :controller do
  before { fake_session admin: true }

  let(:extractor) { build(:external_extractor, key: 'ext') }
  let(:workflow) { create(:workflow, extractors: [extractor]) }

  describe "GET #index" do
    it "returns http success" do
      get :index, params: {workflow_id: workflow.id, extractor_key: extractor.key}
      expect(response).to have_http_status(:success)
    end
  end
end
