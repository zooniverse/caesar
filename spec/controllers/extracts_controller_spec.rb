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

  describe 'PUT #update' do
    let(:subject) { Subject.create! }

    before { allow(ReduceWorker).to receive(:perform_async) }

    it 'creates a new extract' do
      put :update, as: :json,
          params: {workflow_id: workflow.id, extractor_key: extractor.key},
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
                      extractor_key: extractor.key,
                      classification_id: 123,
                      classification_at: 5.days.ago,
                      data: {"foo" => 1})

      put :update, as: :json,
          params: {workflow_id: workflow.id, extractor_key: extractor.key},
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
      expect(ReduceWorker).to have_received(:perform_async).with(workflow.id, subject.id, nil)
    end

    it 'does not trigger reducers if nothing changed' do
      Extract.create!(workflow_id: workflow.id,
                      subject_id: subject.id,
                      extractor_key: extractor.key,
                      classification_id: 123,
                      classification_at: 5.days.ago,
                      data: {"foo" => 1})

      put :update, as: :json,
          params: {workflow_id: workflow.id, extractor_key: extractor.key},
          body: {
            extract: {
              classification_id: 123,
              classification_at: Time.now,
              subject_id: subject.id,
              user_id: nil,
              data: {"foo" => 1}
            }
          }.to_json

      expect(ReduceWorker).not_to have_received(:perform_async)
    end
  end
end
