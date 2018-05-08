require 'rails_helper'

RSpec.describe SubjectReductionsController, type: :controller do
  before { fake_session admin: true }

  let(:reducer_key) { 1 }
  let(:workflow) { create(:workflow) }
  let(:reducer) { create(:external_reducer, reducible: workflow, key: reducer_key) }

  describe "GET #index" do
    it "returns http success" do
      get :index, params: {reducible_id: workflow.id, reducer_key: reducer_key}
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PUT #update' do
    let(:subject) { Subject.create! }

    it 'creates a new reduction' do
      put :update, as: :json,
          params: {reducible_id: workflow.id, reducer_key: reducer_key},
          body: {
            reduction: {
              classification_id: 123,
              classification_at: Time.now,
              subject_id: subject.id,
              user_id: nil,
              data: {"object_present" => true}
            }
          }.to_json

      expect(response).to have_http_status(:success)
      expect(SubjectReduction.count).to eq(1)
    end

    it 'updates an existing reduction' do
      SubjectReduction.create!(reducible_id: workflow.id,
                        subject_id: subject.id,
                        reducer_key: reducer_key,
                        data: {"foo" => 1})

      put :update, as: :json,
          params: {reducible_id: workflow.id, reducer_key: reducer_key},
          body: {
            reduction: {
              classification_id: 123,
              classification_at: Time.now,
              subject_id: subject.id,
              user_id: nil,
              data: {"foo" => 2}
            }
          }.to_json

      expect(response).to have_http_status(:success)
      expect(SubjectReduction.count).to eq(1)
      expect(SubjectReduction.first.data).to eq("foo" => 2)
    end
  end
end
