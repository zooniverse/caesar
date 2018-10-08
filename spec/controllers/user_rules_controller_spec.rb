require 'spec_helper'

RSpec.describe UserRulesController, type: :controller do
  let(:workflow) { create :workflow }

  before { fake_session admin: true }

  describe '#index' do
    it 'lists subject rules for a workflow' do
      rules = [create(:user_rule, workflow: workflow),
                  create(:user_rule, workflow: workflow)]

      get :index, params: {workflow_id: workflow.id}, format: :json
      expect(json_response.map { |i| i["id"] }).to match_array(rules.map(&:id))
    end

    it 'returns empty list when there are no subject rules' do
      get :index, params: {workflow_id: workflow.id}, format: :json
      expect(json_response).to eq([])
    end
  end

  describe '#show' do
    it 'fetches a specified rule by id' do
      rule = create :user_rule, workflow: workflow
      get :show, params: {id: rule.id, workflow_id: workflow.id}, format: :json
      result = JSON.parse(response.body)
      expect(result["id"]).to eq(rule.id)
    end

    it 'returns 404 for a rule that doesnt exist' do
      rule = create :user_rule, workflow: workflow
      get :show, params: {id: rule.id+100, workflow_id: workflow.id}, format: :json
      expect(response.status).to eq(404)
    end
  end

  describe '#create' do
    let(:condition){ ["gte", ["const", 5], ["const", 3]] }

    it 'makes a new rule' do
      condition = ["gte", ["const", 5], ["const", 3]]
      post :create, params: {user_rule: {condition: condition}, workflow_id: workflow.id}, as: :json

      expect(response.status).to eq(200)
      result = JSON.parse(response.body)
      expect(result["id"]).not_to be(nil)
      expect(result["workflow_id"]).to eq(workflow.id)

      new_rule = UserRule.find(result["id"])
      expect(new_rule.condition.to_a).to eq(condition)
    end

    it 'handles a condition_string properly' do
      post :create, params: {
        user_rule: {condition_string: condition.to_json},
        workflow_id: workflow.id
      }, as: :html

      expect(response.status).to eq(302)
      expect(UserRule.count).to eq(1)
    end
  end

  describe '#update' do
    let(:condition){ ["gte", ["const", 5], ["const", 3]] }

    it 'changes a rule' do
      condition1 = ["gte", ["const", 5], ["const", 3]]
      rule = create :user_rule, condition: condition1, workflow: workflow

      condition2 = ["lte", ["const", 5], ["const", 3]]
      put :update, params: {user_rule: {condition: condition2}, workflow_id: workflow.id, id: rule.id}, as: :json

      expect(response.status).to eq(200)
      result = JSON.parse(response.body)
      expect(result["id"]).not_to be(nil)
      expect(result["id"]).to eq(rule.id)
      expect(result["workflow_id"]).to eq(workflow.id)

      new_rule = UserRule.find(rule.id)
      expect(new_rule.condition.to_a).to eq(condition2)
    end

    it 'handles a condition_string properly' do
      rule = create :user_rule, condition: condition, workflow: workflow
      new_condition = ["lte", ["const", 5], ["const", 3]]

      put :update, params: {
        user_rule: {condition_string: new_condition.to_json},
        workflow_id: workflow.id, id: rule.id
      }, as: :html

      expect(response.status).to eq(302)
      expect(UserRule.count).to eq(1)

      new_rule = UserRule.find(rule.id)
      expect(new_rule.condition.to_a).to eq(new_condition)
    end
  end

  describe '#destroy' do
    it 'deletes a rule' do
      rule = create :user_rule, workflow: workflow
      delete :destroy, params: { id: rule.id, workflow_id: workflow.id }, format: :json

      expect(response.status).to eq(204)
      expect(UserRule.where(id: rule.id)).to be_empty
    end
  end

end
