require 'spec_helper'

describe DataRequestsController, :type => :controller do
  let(:uploader) { double("Uploader", "url" => "hi", "upload" => nil)}

  let(:workflow_id){ 4567 }

  let(:request) do
    DataRequest.new(
      workflow_id: workflow_id,
      subgroup: nil,
      requested_data: DataRequest.requested_data[:extracts]
    )
  end

  let(:request_id) do
    request.id
  end

  describe '#request_extracts' do
    it('should require authentication') do
      response = post :request_extracts, params: { workflow_id: workflow_id }
      expect(response.status).to eq(401)
    end

    it('should produce a data request item for a new request') do
      allow_any_instance_of(DataRequestsController).to receive(:authenticated?).and_return(true)
      allow_any_instance_of(DataRequestsController).to receive(:authorized?).and_return(true)

      response = post :request_extracts, params: {
        workflow_id: workflow_id
      }

      expect(response.status).to eq(200)
      expect(DataRequest.count).to eq(1)
      expect(DataRequest.first.extracts?).to be(true)
    end

    it('should store multiple data requests') do
      allow_any_instance_of(DataRequestsController).to receive(:authenticated?).and_return(true)
      allow_any_instance_of(DataRequestsController).to receive(:authorized?).and_return(true)

      response = post :request_extracts, params: {
        workflow_id: workflow_id
      }

      expect(response.status).to eq(200)
      expect(DataRequest.count).to eq(1)

      response = post :request_extracts, params: {
        workflow_id: workflow_id+1
      }

      expect(response.status).to eq(200)
      expect(DataRequest.count).to eq(2)
    end

    it('should reject duplicate requests') do
      allow_any_instance_of(DataRequestsController).to receive(:authenticated?).and_return(true)
      allow_any_instance_of(DataRequestsController).to receive(:authorized?).and_return(true)

      params = {
        workflow_id: workflow_id
      }

      post :request_extracts, params: params
      response = post :request_extracts, params: params

      expect(response.status).to eq(429)
      expect(DataRequest.count).to eq(1)
    end

    it('should restart finished requests') do
      allow_any_instance_of(DataRequestsController).to receive(:authenticated?).and_return(true)
      allow_any_instance_of(DataRequestsController).to receive(:authorized?).and_return(true)

      params = {
        workflow_id: workflow_id
      }

      post :request_extracts, params: params
      DataRequest.first.update_attribute :status, DataRequest.statuses[:complete]
      response = post :request_extracts, params: params

      expect(response.status).to eq(200)
      expect(DataRequest.count).to eq(1)
    end
  end

  describe '#request_reductions' do
    it('should require authentication') do
      response = post :request_reductions, params: { workflow_id: workflow_id }
      expect(response.status).to eq(401)
    end

    it('should produce reduction requests instead of extract requests') do
      allow_any_instance_of(DataRequestsController).to receive(:authenticated?).and_return(true)
      allow_any_instance_of(DataRequestsController).to receive(:authorized?).and_return(true)

      response = post :request_reductions, params: {
        workflow_id: workflow_id
      }

      expect(response.status).to eq(200)
      expect(DataRequest.count).to eq(1)
      expect(DataRequest.first.reductions?).to be(true)
    end
  end

  describe '#check_status' do
    DataRequest.delete_all

    it('should require authentication') do
      response = get :check_status, params: { request_id: 'dsfjksdjfksaljfsad'}
      expect(response.status).to eq(401)
    end

    it('should tell us when there are no matching requests') do
      allow_any_instance_of(DataRequestsController).to receive(:authenticated?).and_return(true)
      allow_any_instance_of(DataRequestsController).to receive(:authorized?).and_return(true)
      response = get :check_status, params: { request_id: 'dsfjksdjfksaljfsad'}

      expect(response.status).to eq(404)
    end

    it('should return the right statuses') do
      allow_any_instance_of(DataRequestsController).to receive(:authenticated?).and_return(true)
      allow_any_instance_of(DataRequestsController).to receive(:authorized?).and_return(true)

      request.pending!
      response = get :check_status, params: { request_id: request_id }
      expect(response.status).to eq(201)

      request.processing!
      response = get :check_status, params: { request_id: request_id }
      expect(response.status).to eq(202)

      request.failed!
      response = get :check_status, params: { request_id: request_id }
      expect(response.status).to eq(500)

      request.complete!
      response = get :check_status, params: { request_id: request_id }
      expect(response.status).to eq(200)
    end
  end

  describe '#retrieve' do
    it('should return 404 if no file is ready') do
      allow_any_instance_of(DataRequestsController).to receive(:authenticated?).and_return(true)
      allow_any_instance_of(DataRequestsController).to receive(:authorized?).and_return(true)

      request.url = nil
      request.save!

      response = get :retrieve, params: { request_id: request_id }
      expect(response.status).to eq(404)
    end

    it('should return the url if the file is available') do
      allow_any_instance_of(DataRequestsController).to receive(:authenticated?).and_return(true)
      allow_any_instance_of(DataRequestsController).to receive(:authorized?).and_return(true)

      request.url = 'foo'
      request.save!

      response = get :retrieve, params: { request_id: request_id }
      expect(response.status).to eq(200)
      expect(response.body).to eq('foo')
    end
  end

  after do
    DataRequest.delete_all
  end

end
