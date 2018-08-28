require 'spec_helper'

describe DataRequestsController, :type => :controller do
  before { fake_session project_ids: [workflow.project_id] }

  let(:uploader) { double("Uploader", "url" => "hi", "upload" => nil)}

  let(:workflow) { create :workflow }

  let(:data_request) do
    DataRequest.new(
      exportable: workflow,
      subgroup: nil,
      requested_data: DataRequest.requested_data[:extracts]
    )
  end

  let(:request_id) do
    data_request.id
  end

  describe '#index' do
    let(:params) { {workflow_id: workflow.id} }

    it 'returns data requests for workflow' do
      data_request1 = create(:data_request, exportable: workflow, created_at: 5.days.ago)
      data_request2 = create(:data_request, exportable: workflow, created_at: 2.days.ago)

      get :index, params: params, format: :json
      expect(json_response).to eq([data_request2.as_json.stringify_keys,
                                   data_request1.as_json.stringify_keys])
    end

    it 'returns public requests for unauthorized users' do
      fake_session(logged_in: false)
      data_request1 = create(:data_request, exportable: workflow, created_at: 5.days.ago, public: true)
      data_request2 = create(:data_request, exportable: workflow, created_at: 2.days.ago)

      get :index, params: params, format: :json
      expect(assigns[:workflow]).to be_nil
      expect(json_response).to eq([data_request1.as_json.stringify_keys])
    end

    it 'assigns workflow' do
      get :index, params: params
      expect(assigns[:workflow]).to eq(workflow)
    end
  end

  describe '#create' do
    describe 'malformed' do
      let(:params) { {workflow_id: workflow.id, data_request: {}} }

      it('responds with the right error code') do
        response = post :create, params: params, format: :json

        expect(response.status).to eq(422)
      end
    end

    describe 'extracts' do
      let(:params) { {workflow_id: workflow.id, data_request: {requested_data: 'extracts'}} }

      it('should produce a data request item for a new request') do
        response = post :create, params: params, format: :json

        expect(response.status).to eq(201)
        expect(DataRequest.count).to eq(1)
        expect(DataRequest.first.extracts?).to be(true)
      end

      context 'when not a project collaborator' do
        it 'returns 401 when workflow does not expose extracts publicly' do
          fake_session(admin: false)
          response = post :create, params: params, format: :json
          expect(response.status).to eq(401)
        end

        it 'allows creating request when workflow exposes extracts publicly' do
          fake_session(admin: false)
          workflow.update! public_extracts: true
          response = post :create, params: params, format: :json
          expect(response.status).to eq(201)
        end
      end
    end

    describe 'reductions' do
      let(:params) { {workflow_id: workflow.id, data_request: {requested_data: 'reductions'}} }

      it('should produce reduction requests instead of extract requests') do
        response = post :create, params: params, format: :json

        expect(response.status).to eq(201)
        expect(DataRequest.count).to eq(1)
        expect(DataRequest.first.reductions?).to be(true)
      end

      context 'when not a project collaborator' do
        it 'returns 401 when workflow does not expose reductions publicly' do
          fake_session(admin: false)
          response = post :create, params: params, format: :json
          expect(response.status).to eq(401)
        end

        it 'allows creating request when workflow exposes reductions publicly' do
          fake_session(admin: false)
          workflow.update! public_reductions: true
          response = post :create, params: params, format: :json
          expect(response.status).to eq(201)
        end
      end
    end
  end

  describe '#show' do
    let(:params) { {workflow_id: workflow.id, id: data_request.id }}

    before { data_request.save! }

    it('should tell us when there are no matching requests') do
      response = get :show, params: params.merge(id: 123312), format: :json
      expect(response.status).to eq(404)
    end

    context 'when not a project collaborator' do
      it 'returns 404 for private requests' do
        fake_session(admin: false)
        response = get :show, params: params, format: :json
        expect(response.status).to eq(404)
      end

      it 'returns public requests for unauthorized users' do
        fake_session(admin: false)
        data_request.update! public: true
        response = get :show, params: params, format: :json
        expect(response.status).to eq(200)
      end
    end

    it('should return the right statuses') do
      data_request.pending!
      response = get :show, params: params, format: :json
      expect(response.status).to eq(200)
      expect(json_response["status"]).to eq("pending")

      data_request.processing!
      response = get :show, params: params, format: :json
      expect(json_response["status"]).to eq("processing")

      data_request.failed!
      response = get :show, params: params, format: :json
      expect(json_response["status"]).to eq("failed")

      data_request.complete!
      response = get :show, params: params, format: :json
      expect(json_response["status"]).to eq("complete")
    end

    it('should return the url if the file is available') do
      data_request.complete!

      response = get :show, params: params, format: :json
      expect(response.status).to eq(200)
      expect(json_response["url"]).to be_present
    end
  end
end
