require 'spec_helper'
require 'ostruct'

describe UserReductionsController, :type => :controller do
    let(:workflow) { create :workflow }
    let(:reducer1) { create :external_reducer, reducible: workflow, key: 'r', topic: :reduce_by_user }
    let(:reducer2) { create :external_reducer, reducible: workflow, key: 's', topic: :reduce_by_user }
    let(:user1_id) { 1234 }
    let(:user2_id) { 2345 }
    let(:reductions) {
    [
      create(:user_reduction, reducible: workflow, user_id: user1_id, reducer_key: reducer1.key, data: {'1' => 1}),
      create(:user_reduction, reducible: workflow, user_id: user1_id, reducer_key: reducer2.key, data: {'2' => 1}),
      create(:user_reduction, reducible: workflow, user_id: user2_id, reducer_key: reducer1.key, data: {'3' => 1})
    ]
  }

  before { fake_session(admin: true) }

  describe '#index' do
    it 'returns only the requested reductions' do
      reductions

      response = get :index, params: { workflow_id: workflow.id, reducer_key: 'r', user_id: user1_id }
      results = JSON.parse(response.body)

      expect(response).to be_successful
      expect(results.size).to be(1)
      expect(results[0]).to include("reducer_key" => "r", "user_id" => user1_id)
      expect(results[0]).not_to include("reducer_key" => "s")
      expect(results[0]).not_to include("user_id" => user2_id)
    end
  end

  describe '#update' do
    before { allow(CheckRulesWorker).to receive(:perform_async) }

    it 'updates an existing reduction' do
      reductions

      post :update, params: {
        workflow_id: workflow.id,
        reducer_key: reducer1.key,
        reduction: {
          user_id: user1_id,
          subgroup: '_default',
          data: { blah: 10 }
        }
      }, as: :json

      updated = UserReduction.find_by(
        reducible_id: workflow.id,
        reducible_type: "Workflow",
        reducer_key: reducer1.key,
        user_id: user1_id
      )

      expect(UserReduction.count).to eq(3)
      expect(updated.id).to eq(reductions[0].id)
      expect(updated.data).to eq("blah" => 10)
      expect(CheckRulesWorker).to have_received(:perform_async).with(workflow.id, "Workflow", user1_id).once
    end

    it 'creates new reductions if needed' do
      reductions

      post :update, params: {
        workflow_id: workflow.id,
        reducer_key: reducer2.key,
        reduction: {
          user_id: user2_id,
          subgroup: '_default',
          data: { blah: 10 }
        }
      }, as: :json

      updated = UserReduction.find_by(
        reducible_id: workflow.id,
        reducible_type: "Workflow",
        reducer_key: reducer2.key,
        user_id: user2_id
      )

      expect(UserReduction.count).to eq(4)
      expect(updated.data).to eq("blah" => 10)
      expect(CheckRulesWorker).to have_received(:perform_async).with(workflow.id, "Workflow", user2_id).once
    end

    it 'does not check rules if nothing changed' do
      reductions

      post :update, params: {
        workflow_id: workflow.id,
        reducer_key: reducer1.key,
        reduction: {
          user_id: user1_id,
          subgroup: '_default',
          data: reductions[0].data
        }
      }, as: :json

      expect(CheckRulesWorker).not_to have_received(:perform_async)
    end
  end
end
