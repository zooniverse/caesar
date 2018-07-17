require 'rails_helper'

RSpec.describe ProjectPolicy do
  subject { described_class }

  permissions ".scope" do
    let!(:projects) do
      create_list(:project, 4)
    end

    it 'returns no records when not logged in' do
      credential = build(:credential, :not_logged_in)
      expect(records_for(credential)).to eq(Project.none)
    end

    it 'returns no records when token has expired' do
      credential = build(:credential, :expired, project_ids: projects.pluck(:id).uniq)
      expect(records_for(credential)).to eq(Project.none)
    end

    it 'returns all projects for an admin' do
      credential = build(:credential, :admin, project_ids: [])
      expect(records_for(credential)).to eq(Project.all)
    end

    it 'returns no projects when not a collaborator on any project' do
      credential = build(:credential, project_ids: [])
      expect(records_for(credential)).to eq(Project.none)
    end

    it 'returns projects that the user is a collaborator on' do
      credential = create(:credential, project_ids: projects.pluck(:id).uniq)
      expect(records_for(credential)).to match_array(Project.all)
    end
  end

  permissions :show?, :create?, :update? do
    let(:project) { create :project}

    it 'denies access when not logged in' do
      credential = build(:credential, :not_logged_in)
      expect(subject).not_to permit(credential, project)
    end

    it 'denies access when token has expired' do
      credential = build(:credential, :expired, project_ids: [project.id])
      expect(subject).not_to permit(credential, project)
    end

    it 'denies access when not a collaborator on the project' do
      credential = build(:credential, project_ids: [])
      expect(subject).not_to permit(credential, project)
    end

    it 'grants access to an admin' do
      credential = build(:credential, :admin, project_ids: [])
      expect(subject).to permit(credential, project)
    end

    it 'grants access to projectsof collaborated project' do
      credential = build(:credential, project_ids: [project.id])
      expect(subject).to permit(credential, project)
    end
  end

  permissions :destroy? do
    it 'denies access to project owner' do
      project = build(:project)
      credential = build(:credential, project_ids: [project.id])
      expect(subject).not_to permit(credential, project)
    end

    it "grants access to admins" do
      project = build(:project)
      credential = build(:credential, :admin)
      expect(subject).to permit(credential, project)
    end
  end
end
