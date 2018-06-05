require 'spec_helper'
require 'ostruct'

describe UserReductionsController, :type => :controller do
  let(:workflow) { create :workflow }
  let(:user1_id) { 1234 }
  let(:user2_id) { 2345 }
  let(:reductions) {
    [
      create(:user_reduction, reducible: workflow, user_id: user1_id, reducer_key: 'r', data: '1'),
      create(:user_reduction, reducible: workflow, user_id: user1_id, reducer_key: 's', data: '2'),
      create(:user_reduction, reducible: workflow, user_id: user2_id, reducer_key: 'r', data: '3')
    ]
  }

  before { fake_session(admin: true) }

  describe '#index' do
    it 'returns only the requested reductions' do
      reductions

      response = get :index, params: { workflow_id: workflow.id, reducer_key: 'r', user_id: user1_id }
      results = JSON.parse(response.body)

      expect(response).to be_success
      expect(results.size).to be(1)
      expect(results[0]).to include("reducer_key" => "r", "user_id" => user1_id)
      expect(results[0]).not_to include("reducer_key" => "s")
      expect(results[0]).not_to include("user_id" => user2_id)
    end
  end

  describe '#update' do
    it 'updates an existing reduction' do
      r = reductions

      #we don't have any real reducers configured, so work around that
      allow_any_instance_of(UserReductionsController).to receive(:reducer).and_return(
        OpenStruct.new(key: 'r')
      )

      post :update, params: {
        workflow_id: workflow.id,
        reducer_key: 'r',
        reduction: {
          user_id: user1_id,
          subgroup: '_default',
          data: { blah: 10 }
        }
      }

      updated = UserReduction.find_by(
        workflow_id: workflow.id,
        reducer_key: 'r',
        user_id: user1_id
      )

      expect(UserReduction.count).to eq(3)
      expect(updated.id).to eq(r[0].id)
      expect(updated.data).to eq("blah" => "10")
    end

    it 'creates new reductions if needed' do
      reductions

      #we don't have any real reducers configured, so work around that
      allow_any_instance_of(UserReductionsController).to receive(:reducer).and_return(
        OpenStruct.new(key: 'q')
      )

      post :update, params: {
        workflow_id: workflow.id,
        reducer_key: 'q',
        reduction: {
          user_id: user1_id,
          subgroup: '_default',
          data: { blah: 10 }
        }
      }

      updated = UserReduction.find_by(
        reducible_id: workflow.id,
        reducible_type: "workflow",
        reducer_key: 'q',
        user_id: user1_id
      )

      expect(UserReduction.count).to eq(4)
      expect(updated.data).to eq("blah" => "10")
    end
  end
end
