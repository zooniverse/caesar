require 'spec_helper'

describe DataRequestsController, :type => :controller do
  before { fake_session admin: true }

  let(:uploader) { double("Uploader", "url" => "hi", "upload" => nil)}

  let(:workflow){ create :workflow }

  let(:data_request) do
    DataRequest.new(
      workflow: workflow,
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
      data_request1 = create(:data_request, workflow: workflow, created_at: 5.days.ago)
      data_request2 = create(:data_request, workflow: workflow, created_at: 2.days.ago)

      response = get :index, params: params, format: :json
      expect(json_response).to eq([data_request2.as_json.stringify_keys,
                                   data_request1.as_json.stringify_keys])
    end
  end

  describe '#new' do
    describe 'extracts' do
      let(:params) { {workflow_id: workflow.id, data_request: {requested_data: 'extracts'}} }

      it('should produce a data request item for a new request') do
        response = post :new, params: params, format: :json

        expect(response.status).to eq(201)
        expect(DataRequest.count).to eq(1)
        expect(DataRequest.first.extracts?).to be(true)
      end
    end

    describe 'reductions' do
      let(:params) { {workflow_id: workflow.id, data_request: {requested_data: 'reductions'}} }

      it('should produce reduction requests instead of extract requests') do
        response = post :new, params: params, format: :json

        expect(response.status).to eq(201)
        expect(DataRequest.count).to eq(1)
        expect(DataRequest.first.reductions?).to be(true)
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

    it('should return 404 if no file is ready') do
      data_request.url = nil
      data_request.save!

      response = get :show, params: params, format: :json
      expect(response.status).to eq(200)
    end

    it('should return the url if the file is available') do
      data_request.url = 'foo'
      data_request.save!

      response = get :show, params: params, format: :json
      expect(response.status).to eq(200)
      expect(json_response["url"]).to eq('foo')
    end
  end
end
