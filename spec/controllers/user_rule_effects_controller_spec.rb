require 'spec_helper'

RSpec.describe UserRuleEffectsController, type: :controller do
  let(:workflow) { create :workflow }
  let(:rule) { create :user_rule, workflow: workflow }

  context 'as a permissioned user' do
    before{ fake_session admin: false, project_ids: [workflow.project_id], logged_in: true }

    describe '#destroy' do
      it 'lets a user delete user_rule_effects if they own the workflow' do
        ure2 = create :user_rule_effect, user_rule: rule
        response = delete :destroy, params: { id: ure2.id, workflow_id: workflow.id, user_rule_id: rule.id }, format: :json

        expect(response.status).to eq(204)
        expect(UserRuleEffect.find_by_id(ure2.id)).to be(nil)
      end

      it 'does not let a user delete user_rule_effects if they do not own the workflow' do
        other_workflow = create :workflow, project_id: workflow.project_id + 1
        other_rule = create :user_rule, workflow: other_workflow
        ure2 = create :user_rule_effect, user_rule: other_rule
        response = delete :destroy, params: { id: ure2.id, workflow_id: other_workflow.id, user_rule_id: other_rule.id }, format: :json

        expect(response.status).to eq(404)
        expect(UserRuleEffect.find_by_id(ure2.id)).not_to be(nil)
      end
    end
  end

  context 'as an admin' do
    before { fake_session admin: true }

    describe '#index' do
      it 'lists effects for a rule' do
        rules = [create(:user_rule_effect, user_rule: rule),
                    create(:user_rule_effect, user_rule: rule)]

        get :index, params: {workflow_id: workflow.id, user_rule_id: rule.id}, format: :json
        expect(json_response.map { |i| i["id"] }).to match_array(rules.map(&:id))
      end

      it 'returns empty list when there are no user rules' do
        get :index, params: {workflow_id: workflow.id, user_rule_id: rule.id}, format: :json
        expect(json_response).to eq([])
      end
    end

    describe "#show" do
      it 'shows a particular effect' do
        effect = create :user_rule_effect, user_rule: rule
        get :show, params: { id: effect.id, user_rule_id: rule.id, workflow_id: workflow.id }, format: :json
        result = JSON.parse(response.body)
        expect(result["id"]).to eq(effect.id)
      end

      it 'returns 404 for an effect that doesnt exist' do
        effect = create :user_rule_effect, user_rule: rule
        get :show, params: {id: effect.id+100, user_rule_id: rule.id, workflow_id: workflow.id}, format: :json
        expect(response.status).to eq(404)
      end
    end

    describe "#create" do
      it 'makes a new effect' do
        post :create, params: {user_rule_effect: {action: 'promote_user', config: { workflow_id: 1234 }}, workflow_id: workflow.id, user_rule_id: rule.id }, format: :json

        expect(response.status).to eq(200)
        result = JSON.parse(response.body)
        expect(result["id"]).not_to be(nil)
        expect(result["user_rule_id"]).to eq(rule.id)
      end

      it 'redirects to the user rule in html mode' do
        post :create, params: {user_rule_effect: {action: 'promote_user', config: { workflow_id: 1234 }}, workflow_id: workflow.id, user_rule_id: rule.id }, format: :html
        expect(response).to redirect_to(edit_workflow_user_rule_path(workflow,rule))
      end
    end

    describe "#update" do
      it 'changes an effect' do
        effect = create :user_rule_effect, action: 'promote_user', config: { workflow_id: 1234 }, user_rule: rule
        put :update, params: { user_rule_effect: { config: { workflow_id: 2345 }}, id: effect.id, user_rule_id: rule.id, workflow_id: workflow.id }, format: :json

        expect(response.status).to eq(204)
        effect = UserRuleEffect.find(effect.id)
        expect(effect.config['workflow_id']).to eq('2345')
      end

      it 'redirects to the user rule in html mode' do
        effect = create :user_rule_effect, action: 'promote_user', config: { workflow_id: '1234' }, user_rule: rule
        put :update, params: { user_rule_effect: { config: { workflow_id: '2345' }}, id: effect.id, user_rule_id: rule.id, workflow_id: workflow.id }, format: :html
        expect(response).to redirect_to(edit_workflow_user_rule_path(workflow,rule))
      end
    end

    describe '#destroy' do
      it 'destroys an effect' do
        effect = create :user_rule_effect, action: 'promote_user', config: { workflow_id: 1234 }, user_rule: rule
        delete :destroy, params: { id: effect.id, user_rule_id: rule.id, workflow_id: workflow.id }, format: :json

        expect(response.status).to eq(204)
        expect(UserRuleEffect.where(id: effect.id)).to be_empty
      end
    end
  end
end
