require 'rails_helper'

RSpec.describe ProjectPolicy do
  subject { described_class }
  let(:not_logged_in_credential){ fake_credential logged_in: false }
  let(:expired_credential){ fake_credential expired: true }
  let(:admin_credential){ fake_credential admin: true }


  permissions ".scope" do
    let!(:projects) do
      create_list(:project, 4)
    end

    it 'returns no records when not logged in' do
      expect(records_for(not_logged_in_credential)).to eq(Project.none)
    end

    it 'returns no records when token has expired' do
      expect(records_for(expired_credential)).to eq(Project.none)
    end

    it 'returns all projects for an admin' do
      expect(records_for(admin_credential)).to eq(Project.all)
    end

    it 'returns no projects when not a collaborator on any project' do
      credential = fake_credential project_ids: []
      expect(records_for(credential)).to eq(Project.none)
    end

    it 'returns projects that the user is a collaborator on' do
      credential = fake_credential project_ids: projects.pluck(:id).uniq
      expect(records_for(credential)).to match_array(Project.all)
    end
  end

  permissions :show?, :create?, :update? do
    let(:project) { create :project}

    it 'denies access when not logged in' do
      expect(subject).not_to permit(not_logged_in_credential, project)
    end

    it 'denies access when token has expired' do
      expect(subject).not_to permit(expired_credential, project)
    end

    it 'denies access when not a collaborator on the project' do
      credential = fake_credential project_ids: []
      expect(subject).not_to permit(credential, project)
    end

    it 'grants access to an admin' do
      expect(subject).to permit(admin_credential, project)
    end

    it 'grants access to projects of collaborated project' do
      credential = fake_credential project_ids: [project.id]
      expect(subject).to permit(credential, project)
    end
  end

  permissions :destroy? do
    it 'denies access to project owner' do
      project = build(:project)
      credential = fake_credential project_ids: [project.id]
      expect(subject).not_to permit(credential, project)
    end

    it "grants access to admins" do
      project = build(:project)
      expect(subject).to permit(admin_credential, project)
    end
  end
end
