require 'rails_helper'

RSpec.describe Workflow, type: :model do
  let(:workflow) { Workflow.new }

  describe 'public_data?' do
    describe 'public extracts' do
      it 'is true' do
        workflow.public_extracts = true
        expect(workflow.public_data?("extracts")).to be_truthy
      end

      it 'is false' do
        workflow.public_extracts = false
        expect(workflow.public_data?("extracts")).to be_falsey
      end
    end

    describe 'public reductions' do
      it 'is true' do
        workflow.public_reductions = true
        expect(workflow.public_data?("reductions")).to be_truthy
      end

      it 'is false' do
        workflow.public_reductions = false
        expect(workflow.public_data?("reductions")).to be_falsey
      end
    end

    it 'is false for any other data type' do
      expect(workflow.public_data?("foobar")).to be_falsey
    end
  end
end
