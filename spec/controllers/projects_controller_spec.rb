require 'spec_helper'

describe ProjectsController, type: :controller do
  before { fake_session admin: true }

  describe 'GET #index' do
    it 'returns json' do
      create :project
      get :index, format: :json
      expect(response).to have_http_status(:success)

      projects = JSON.parse(response.body)
      expect(projects.length).to eq(1)
    end
  end

  describe 'GET #show' do
    it 'returns json' do
      project = create :project
      get :show, format: :json, params: {id: project.id}

      expect(response).to have_http_status(:success)
      new_project = JSON.parse(response.body)
      expect(new_project['id']).to eq(project.id)
    end
  end

  describe 'POST #create' do
    it 'adds the project if it is accessible' do
      allow(@credential).to receive(:accessible_project?).and_return(true)
      post :create, params: { project: { id: 9, display_name: 'nein' } }, format: :json
      expect(response.status).to eq(201)
    end

    it 'does not add inaccessible projects' do
      allow(@credential).to receive(:accessible_project?).and_return(false)
      post :create, params: { project: { id: 9, display_name: 'nein' } }, format: :json
      expect(response.status).to eq(403)
    end

    it 'redirects with a 302 if the project already exists' do
      allow(@credential).to receive(:accessible_project?).and_return(true)
      project = create :project
      post :create, params: { project: { id: project.id } }, format: :json
      expect(response).to redirect_to project
      expect(response.status).to eq(302)
      expect(flash[:alert]).to be_present
    end
  end

  describe 'PUT #update' do
    it 'updates the project' do
      create :project, id: 8, display_name: 'seven'
      put :update, params: {project:{display_name: 'eight'}, id: 8}, format: :json

      expect(response.status).to eq(204)
      project = Project.find(8)
      expect(project.display_name).to eq('seven')
    end
  end
end
