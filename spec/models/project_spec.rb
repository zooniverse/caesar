require 'rails_helper'

RSpec.describe Project, type: :model do
  let(:project) { Project.new }

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
end
