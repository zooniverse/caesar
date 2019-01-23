require 'rails_helper'

RSpec.describe Project, type: :model do
  let(:project) { Project.new }
  let(:subject) { create :subject }

  describe 'public_data?' do
    describe 'public reductions' do
      it 'is true' do
        project.public_reductions = true
        expect(project.public_data?("reductions")).to be_truthy
      end

      it 'is false' do
        project.public_reductions = false
        expect(project.public_data?("reductions")).to be_falsey
      end
    end

    it 'is false for any other data type' do
      expect(project.public_data?("foobar")).to be_falsey
    end
  end

  describe 'cached counters' do
    it 'increments the subject reduction count when new reductions are added' do
      SubjectReduction.create! reducible: project, subject_id: subject.id, reducer_key: 'key'
      expect(Project.find(project.id).subject_reductions_count).to eq(1)
    end

    it 'increments the user reduction count when new reductions are added' do
      UserReduction.create! reducible: project, user_id: 12345, reducer_key: 'key'
      expect(Project.find(project.id).user_reductions_count).to eq(1)
    end
  end

  describe 'IsReducible' do
    it 'can re-run reducers' do
      expect{project.rerun_reducers}.not_to raise_error
    end
  end
end
