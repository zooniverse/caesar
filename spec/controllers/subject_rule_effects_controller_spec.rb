require 'spec_helper'

RSpec.describe SubjectRuleEffectsController, type: :controller do
  let(:workflow) { create :workflow }
  let(:rule) { create :subject_rule, workflow: workflow }

  before { fake_session admin: true }

  describe '#index' do
    it 'lists effects for a rule' do
      rules = [create(:subject_rule_effect, subject_rule: rule),
                  create(:subject_rule_effect, subject_rule: rule)]

      get :index, params: {workflow_id: workflow.id, subject_rule_id: rule.id}, format: :json
      json_response = JSON.parse(response.body)
      expect(json_response.map { |i| i["id"] }).to match_array(rules.map(&:id))
    end

    it 'returns empty list when there are no subject rules' do
      get :index, params: {workflow_id: workflow.id, subject_rule_id: rule.id}, format: :json
      json_response = JSON.parse(response.body)
      expect(json_response).to eq([])
    end
  end

  describe "#show" do
    it 'shows a particular effect' do
      effect = create :subject_rule_effect, subject_rule: rule
      get :show, params: { id: effect.id, subject_rule_id: rule.id, workflow_id: workflow.id }, format: :json
      result = JSON.parse(response.body)
      expect(result["id"]).to eq(effect.id)
    end

    it 'returns 404 for an effect that doesnt exist' do
      effect = create :subject_rule_effect, subject_rule: rule
      get :show, params: {id: effect.id+100, subject_rule_id: rule.id, workflow_id: workflow.id}, format: :json
      expect(response.status).to eq(404)

      get :show, params: {id: effect.id+100, subject_rule_id: rule.id, workflow_id: workflow.id}, format: :html
      expect(response.status).to eq(404)
    end
  end

  describe "#create" do
    it 'makes a new effect' do
      post :create, params: {subject_rule_effect: {action: 'retire_subject', config: {}}, workflow_id: workflow.id, subject_rule_id: rule.id }, format: :json

      expect(response.status).to eq(201)
      result = JSON.parse(response.body)
      expect(result["id"]).not_to be(nil)
      expect(result["subject_rule_id"]).to eq(rule.id)
    end

    it 'redirects to the subject rule in html mode' do
      post :create, params: {subject_rule_effect: {action: 'retire_subject', config: {}}, workflow_id: workflow.id, subject_rule_id: rule.id }, format: :html

      expect(response).to redirect_to(edit_workflow_subject_rule_path(workflow.id, rule.id))
    end
  end

  describe "#update" do
    it 'changes an effect' do
      effect = create :subject_rule_effect, action: 'retire_subject', config: { foo: 'bar' }, subject_rule: rule
      put :update, params: { subject_rule_effect: { config: { foo: 'baz' }}, id: effect.id, subject_rule_id: rule.id, workflow_id: workflow.id }, format: :json

      expect(response.status).to eq(204)
      effect = SubjectRuleEffect.find(effect.id)
      expect(effect.config['foo']).to eq('baz')
    end

    it 'redirects to the subject rule in html mode' do
      effect = create :subject_rule_effect, action: 'retire_subject', config: { foo: 'bar' }, subject_rule: rule
      put :update, params: { subject_rule_effect: { config: { foo: 'baz' }}, id: effect.id, subject_rule_id: rule.id, workflow_id: workflow.id }, format: :html

      expect(response).to redirect_to(edit_workflow_subject_rule_path(workflow.id, rule.id))
    end
  end

  describe '#destroy' do
    it 'destroys an effect' do
      effect = create :subject_rule_effect, action: 'retire_subject', config: { foo: 'bar' }, subject_rule: rule
      delete :destroy, params: { id: effect.id, subject_rule_id: rule.id, workflow_id: workflow.id }, format: :json

      expect(response.status).to eq(204)
      expect(SubjectRuleEffect.where(id: effect.id)).to be_empty
    end
  end
end
