require 'rails_helper'

RSpec.describe Workflow, type: :model do
  let(:workflow) { Workflow.new }

  describe 'activate!' do
    it 'activates the workflow' do
      paused_workflow = create :workflow, status: 'paused'
      paused_workflow.activate!

      expect(paused_workflow.active?).to be(true)
    end

    it 'queues up pending classifications if any existed' do
      subject = create :subject
      paused_workflow = create :workflow, status: 'paused'
      paused_workflow.pending_classifications << create(:classification, workflow_id: paused_workflow.id, subject_id: subject.id)

      expect { paused_workflow.activate! }.
        to change(ExtractWorker.jobs, :size).by(1)
    end

    it 'leaves no pending classifications' do
      subject = create :subject
      paused_workflow = create :workflow, status: 'paused'
      paused_workflow.pending_classifications << create(:classification, workflow_id: paused_workflow.id, subject_id: subject.id)
      paused_workflow.activate!

      expect(paused_workflow.pending_classifications).to be_empty
    end
  end

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
