require 'spec_helper'
require 'ostruct'

describe SubjectReductionsController, :type => :controller do
  let(:workflow) { create :workflow }
  let(:reducer1) { create :external_reducer, reducible: workflow, key: 'r' }
  let(:reducer2) { create :external_reducer, reducible: workflow, key: 's' }
  let(:subject1) { create :subject }
  let(:subject2) { create :subject }
  let(:reductions) {
    [
      create(:subject_reduction, reducible: workflow, subject: subject1, reducer_key: reducer1.key, data: {'1' => 1}),
      create(:subject_reduction, reducible: workflow, subject: subject1, reducer_key: reducer2.key, data: {'2' => 1}),
      create(:subject_reduction, reducible: workflow, subject: subject2, reducer_key: reducer1.key, data: {'3' => 1})
    ]
  }

  before { fake_session(admin: true) }

  describe '#index' do
    it 'returns only the requested reductions' do
      reductions

      response = get :index, params: { workflow_id: workflow.id, reducer_key: 'r', subject_id: subject1.id }
      results = JSON.parse(response.body)

      expect(response).to be_successful
      expect(results.size).to be(1)
      expect(results[0]).to include("reducer_key" => "r", "subject_id" => subject1.id)
      expect(results[0]).not_to include("reducer_key" => "s")
      expect(results[0]).not_to include("subject_id" => subject2.id)
    end
  end

  describe '#update' do
    before { allow(CheckRulesWorker).to receive(:perform_async) }

    it 'updates an existing reduction' do
      r = reductions

      #we don't have any real reducers configured, so work around that
      allow_any_instance_of(SubjectReductionsController).to receive(:reducer).and_return(
        OpenStruct.new(key: 'r')
      )

      post :update, params: {
        workflow_id: workflow.id,
        reducer_key: 'r',
        reduction: {
          subject_id: subject1.id,
          subgroup: '_default',
          data: { blah: 10 }
        }
      }, as: :json

      updated = SubjectReduction.find_by(
        reducible_id: workflow.id,
        reducible_type: "Workflow",
        reducer_key: 'r',
        subject_id: subject1.id
      )

      expect(SubjectReduction.count).to eq(3)
      expect(updated.id).to eq(r[0].id)
      expect(updated.data).to eq("blah" => 10)
      expect(CheckRulesWorker).to have_received(:perform_async).with(workflow.id, "Workflow", subject1.id).once
    end

    it 'creates new reductions if needed' do
      reductions

      post :update, params: {
        workflow_id: workflow.id,
        reducer_key: reducer2.key,
        reduction: {
          subject_id: subject2.id,
          subgroup: '_default',
          data: { blah: 10 }
        }
      }, as: :json

      updated = SubjectReduction.find_by(
        workflow_id: workflow.id,
        reducer_key: reducer2.key,
        subject_id: subject2.id
      )

      expect(SubjectReduction.count).to eq(4)
      expect(updated.data).to eq("blah" => 10)
      expect(CheckRulesWorker).to have_received(:perform_async).with(workflow.id, "Workflow", subject2.id).once
    end

    it 'does not trigger rules if nothing changed' do
      reductions

      post :update, params: {
        workflow_id: workflow.id,
        reducer_key: reducer1.key,
        reduction: {
          subject_id: subject1.id,
          subgroup: '_default',
          data: reductions[0].data
        }
      }, as: :json

      expect(CheckRulesWorker).not_to have_received(:perform_async)
    end
  end
end
