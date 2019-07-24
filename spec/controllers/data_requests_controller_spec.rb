require 'spec_helper'

describe DataRequestsController, :type => :controller do
  before { fake_session project_ids: [workflow.project_id] }

  let(:uploader) { double("Uploader", "url" => "hi", "upload" => nil)}

  let(:project) { create :project, id: 234}
  let(:workflow) { create :workflow, project_id: project.id }

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

  describe '#show' do
    let(:public_workflow){ create :workflow, public_reductions: true }

    context 'when authenticated' do
      it 'returns a public data request' do
        data_request = create :data_request,
          exportable: public_workflow,
          requested_data: 'subject_reductions',
          public: true

        params = { workflow_id: public_workflow.id, id: data_request.id }

        response = get :show, params: params, format: :json
        expect(response.status).to eq(200)
      end

      it 'returns a not public data request' do
        data_request = create :data_request,
          exportable: workflow,
          requested_data: 'subject_reductions',
          public: false

        params = { workflow_id: workflow.id, id: data_request.id }

        response = get :show, params: params, format: :json
        expect(response.status).to eq(200)
      end
    end

    context 'when not authenticated' do
      it 'returns a public data request' do
        fake_session logged_in: false
        data_request = create :data_request,
          exportable: public_workflow,
          requested_data: 'subject_reductions',
          public: true

        params = { workflow_id: public_workflow.id, id: data_request.id }

        response = get :show, params: params, format: :json
        expect(response.status).to eq(200)
      end

      it 'does not return a not public data request' do
        fake_session logged_in: false
        data_request = create :data_request,
          exportable: workflow,
          requested_data: 'subject_reductions',
          public: false

        params = { workflow_id: workflow.id, id: data_request.id }

        response = get :show, params: params, format: :json
        expect(response.status).to eq(404)
      end
    end

    it 'does not return the data request when not authenticated' do
      fake_session(logged_in: false)
    end

    it 'returns the data request when not authenticated if data request is public' do
      fake_session(logged_in: false)
    end
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
      create(:data_request, exportable: workflow, created_at: 2.days.ago)

      get :index, params: params, format: :json
      expect(assigns[:workflow]).to be_nil
      expect(json_response).to eq([data_request1.as_json.stringify_keys])
    end

    it 'assigns workflow' do
      get :index, params: params
      expect(assigns[:workflow]).to eq(workflow)
    end

    it 'responds with 404 to unknown workflow' do
      response = nil
      expect do
        response = get :index, params: { workflow_id: workflow.id + 1 }, format: :json
      end.not_to raise_error

      expect(response.status).to eq(404)
    end
  end

  describe '#create' do
    describe 'malformed' do
      let(:data_request){ { requested_data: 'subject_reductions', subgroup: 'foo' } }
      let(:empty_params) { { workflow_id: workflow.id, data_request: {} } }
      let(:bad_params) { { workflow_id: workflow.id, data_request: { requested_data: 'reductions' } } }
      let(:ok_params) { { workflow_id: workflow.id, data_request: data_request } }

      it 'responds with the right error code' do
        response = post :create, params: empty_params, format: :json
        expect(response.status).to eq(422)

        response = post :create, params: bad_params, format: :json
        expect(response.status).to eq(422)
      end

      it 'saves the subgroup parameter' do
        response = post :create, params: ok_params, format: :json
        resp = JSON.parse(response.body)
        expect(resp.fetch('subgroup', nil)).not_to be_nil
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

    describe 'project reductions' do
      let(:project) { create :project }
      let(:params) { {project_id: project.id, data_request: {requested_data: 'subject_reductions', exportable_id: project.id, exportable_type: 'Project'}} }

      it 'should let me create a data request for a project' do
        fake_session project_ids: [project.id]
        response = post :create, params: params, format: :json

        expect(response.status).to eq(201)
        expect(DataRequest.count).to eq(1)
        expect(DataRequest.first.subject_reductions?).to be(true)
      end
    end

    describe 'reductions' do
      let(:params) { {workflow_id: workflow.id, data_request: {requested_data: 'subject_reductions', exportable_id: workflow.id, exportable_type: 'Workflow'}} }

      it 'sets the public flag' do
        public_workflow = create :workflow, public_reductions: true
        response = post :create, params: {
          workflow_id: public_workflow.id,
          data_request: { requested_data: 'subject_reductions' },
        }, format: :json

        req = DataRequest.find(JSON.parse(response.body)['id'])
        expect(req.public).to be(true)
      end

      it('should produce reduction requests instead of extract requests') do
        response = post :create, params: params, format: :json

        expect(response.status).to eq(201)
        expect(DataRequest.count).to eq(1)
        expect(DataRequest.first.subject_reductions?).to be(true)
      end

      it('should produce user reduction requests when asked') do
        params = {workflow_id: workflow.id, data_request: {requested_data: 'user_reductions', exportable_id: workflow.id, exportable_type: 'Workflow'}}
        response = post :create, params: params, format: :json

        expect(response.status).to eq(201)
        expect(DataRequest.count).to eq(1)
        expect(DataRequest.first.user_reductions?).to be(true)
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
