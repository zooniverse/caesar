require 'spec_helper'

RSpec.describe SubjectRuleEffectsController, type: :controller do
  let(:workflow) { create :workflow }
  let(:rule) { create :subject_rule, workflow: workflow }
  let(:credentials) do
    fake_session admin: false, project_ids: [workflow.project_id], logged_in: true
  end

  context 'as a permissioned user'  do
    before{ credentials }

    describe '#create' do
      let(:create_params) do
        {
          subject_rule_effect: { action: 'retire_subject', config: {} },
          workflow_id: workflow.id,
          subject_rule_id: rule.id
        }
      end

      it 'does not create a new effect' do
        post :create, params: create_params, format: :json
        expect(response.status).to eq(401)
      end

      it 'redirects to the new path in html mode' do
        post :create, params: create_params, format: :html
        expect(response).to redirect_to(
          new_workflow_subject_rule_subject_rule_effect_path
        )
      end

      it "flashes an error message" do
        post :create, params: create_params, format: :html
        expect(flash[:alert]).to eq('Error creating a subject effect rule')
      end

      xit 'makes a new effect' do
        post :create, params: {subject_rule_effect: {action: 'retire_subject', config: {}}, workflow_id: workflow.id, subject_rule_id: rule.id }, format: :json

        expect(response.status).to eq(201)
        result = JSON.parse(response.body)
        expect(result["id"]).not_to be(nil)
        expect(result["subject_rule_id"]).to eq(rule.id)
      end

      xit 'redirects to the subject rule in html mode' do
        post :create, params: {subject_rule_effect: {action: 'retire_subject', config: {}}, workflow_id: workflow.id, subject_rule_id: rule.id }, format: :html
        expect(response).to redirect_to(edit_workflow_subject_rule_path(workflow,rule))
      end
    end

    describe '#update' do
      let(:effect) do
        create :subject_rule_effect, action: 'retire_subject', config: { foo: 'bar' }, subject_rule: rule
      end
      let(:update_params) do
        {
          subject_rule_effect: { config: { foo: 'baz' } },
          id: effect.id,
          subject_rule_id: rule.id,
          workflow_id: workflow.id
        }
      end

      it 'does not update a subject rule effect' do
        put :update, params: update_params, format: :json
        expect(response.status).to eq(401)
      end

      it 'redirects to the edit path in html mode' do
        put :update, params: update_params, format: :html
        expect(response).to redirect_to(
          edit_workflow_subject_rule_subject_rule_effect_path(effect)
        )
      end

      it "flashes an error message" do
        put :update, params: update_params, format: :html
        expect(flash[:alert]).to eq('Error updating a subject effect rule')
      end

      xit 'changes an effect' do
        effect = create :subject_rule_effect, action: 'retire_subject', config: { foo: 'bar' }, subject_rule: rule
        put :update, params: { subject_rule_effect: { config: { foo: 'baz' }}, id: effect.id, subject_rule_id: rule.id, workflow_id: workflow.id }, format: :json

        expect(response.status).to eq(204)
        effect = SubjectRuleEffect.find(effect.id)
        expect(effect.config['foo']).to eq('baz')
      end

      xit 'redirects to the subject rule in html mode' do
        effect = create :subject_rule_effect, action: 'retire_subject', config: { foo: 'bar' }, subject_rule: rule
        put :update, params: { subject_rule_effect: { config: { foo: 'baz' }}, id: effect.id, subject_rule_id: rule.id, workflow_id: workflow.id }, format: :html
        expect(response).to redirect_to(edit_workflow_subject_rule_path(workflow,rule))
      end
    end

    describe '#destroy' do
      let(:effect) do
        create :subject_rule_effect, action: 'retire_subject', config: { foo: 'bar' }, subject_rule: rule
      end
      let(:delete_params) do
        { id: effect.id, subject_rule_id: rule.id, workflow_id: workflow.id }
      end

      it 'destroys an effect' do
        delete :destroy, params: delete_params, format: :json

        expect(response.status).to eq(204)
        expect(SubjectRuleEffect.where(id: effect.id)).to be_empty
      end

      context 'as a user without rights' do
        let(:credentials) do
          fake_session admin: false, project_ids: [], logged_in: true
        end

        it 'does not destroy the effect' do
          delete :destroy, params: delete_params, format: :json

          expect(response.status).to eq(401)
        end
      end
    end
  end

  context 'as an admin' do
    before { fake_session admin: true }

    describe '#index' do
      it 'lists effects for a rule' do
        rules = [create(:subject_rule_effect, subject_rule: rule),
                    create(:subject_rule_effect, subject_rule: rule)]

        get :index, params: {workflow_id: workflow.id, subject_rule_id: rule.id}, format: :json
        expect(json_response.map { |i| i["id"] }).to match_array(rules.map(&:id))
      end

      it 'returns empty list when there are no subject rules' do
        get :index, params: {workflow_id: workflow.id, subject_rule_id: rule.id}, format: :json
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
        expect(response).to redirect_to(edit_workflow_subject_rule_path(workflow,rule))
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
        expect(response).to redirect_to(edit_workflow_subject_rule_path(workflow,rule))
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
end
