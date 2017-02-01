require 'rails_helper'

RSpec.describe ExtractsController, type: :controller do
  describe "GET #index" do
    it "returns http success" do
      get :index, params: {workflow_id: 1, extractor_id: 1}
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PUT #update' do
    let(:extractor_id) { 1 }
    let(:extractor_config) { {"type" => "external"} }
    let(:workflow) { Workflow.create!(extractors_config: {extractor_id => extractor_config}) }
    let(:subject) { Subject.create! }

    it 'creates a new extract' do
      put :update, as: :json,
          params: {workflow_id: workflow.id, extractor_id: extractor_id},
          body: {
            extract: {
              classification_id: 123,
              classification_at: Time.now,
              subject_id: subject.id,
              user_id: nil,
              data: {"object_present" => true}
            }
          }.to_json

      expect(response).to have_http_status(:success)
      expect(Extract.count).to eq(1)
    end

    it 'updates an existing extract' do
      Extract.create!(workflow_id: workflow.id,
                      subject_id: subject.id,
                      extractor_id: extractor_id,
                      data: {"foo" => 1})

      put :update, as: :json,
          params: {workflow_id: workflow.id, extractor_id: extractor_id},
          body: {
            extract: {
              classification_id: 123,
              classification_at: Time.now,
              subject_id: subject.id,
              user_id: nil,
              data: {"foo" => 2}
            }
          }.to_json

      expect(response).to have_http_status(:success)
      expect(Extract.count).to eq(1)
      expect(Extract.first.data).to eq("foo" => 2)
    end
  end
end
