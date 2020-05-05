require 'spec_helper'

RSpec.describe SubjectRuleEffectsController, type: :controller do
  let(:workflow) { create :workflow }
  let(:rule) { create :subject_rule, workflow: workflow }
  let(:credentials) do
    fake_session admin: false, project_ids: [workflow.project_id], logged_in: true
  end

  context 'as a user with permissions to workflow' do
    before { credentials }

    describe '#create' do
      context 'when effect does not add subjects to set or collection' do
        let(:create_params) do
          {
            subject_rule_effect: { action: 'retire_subject', config: {} },
            workflow_id: workflow.id,
            subject_rule_id: rule.id
          }
        end

        it 'makes a new effect' do
          post :create, params: create_params, format: :json

          expect(response.status).to eq(201)
          result = JSON.parse(response.body)
          expect(result['id']).not_to be(nil)
          expect(result['subject_rule_id']).to eq(rule.id)
        end

        it 'redirects to the subject rule in html mode' do
          post :create, params: create_params, format: :html
          expect(response).to redirect_to(edit_workflow_subject_rule_path(workflow, rule))
        end
      end

      context 'when effect adds subjects to set' do
        let(:create_params) do
          {
            subject_rule_effect: { action: 'add_subject_to_set', config: { 'subject_set_id': 777 } },
            workflow_id: workflow.id,
            subject_rule_id: rule.id
          }
        end

        context 'when user does not have permission to that set' do
          before do
            allow_any_instance_of(SubjectRuleEffectPolicy).to receive(:create?).and_return(false)
          end

          it 'does not create a new effect' do
            post :create, params: create_params, format: :json
            expect(response.status).to eq(401)
          end

          it 'redirects to the new path in html mode' do
            post :create, params: create_params, format: :html
            action_type = create_params.dig(:subject_rule_effect, :action)
            expect(response).to redirect_to(
              new_workflow_subject_rule_subject_rule_effect_path(action_type: action_type)
            )
          end

          it 'flashes an error message' do
            post :create, params: create_params, format: :html
            msg = 'You do not have permission to create a subject rule effect for this project.'
            expect(flash[:alert]).to eq(msg)
          end
        end

        context 'when user has permission to that set' do
          before do
            allow_any_instance_of(SubjectRuleEffectPolicy).to receive(:create?).and_return(true)
          end

          it 'makes a new effect' do
            post :create, params: create_params, format: :json

            expect(response.status).to eq(201)
            result = JSON.parse(response.body)
            expect(result['id']).not_to be(nil)
            expect(result['subject_rule_id']).to eq(rule.id)
          end

          it 'redirects to the subject rule in html mode' do
            post :create, params: create_params, format: :html
            expect(response).to redirect_to(edit_workflow_subject_rule_path(workflow, rule))
          end
        end
      end
    end

    describe '#update' do
      context 'when effect does not add subjects to set or collection' do
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

        it 'changes an effect' do
          put :update, params: update_params, format: :json

          expect(response.status).to eq(204)
          effect_record = SubjectRuleEffect.find(effect.id)
          expect(effect_record.config['foo']).to eq('baz')
        end

        it 'redirects to the subject rule in html mode' do
          put :update, params: update_params, format: :html
          expect(response).to redirect_to(edit_workflow_subject_rule_path(workflow, rule))
        end
      end

      context 'when effect adds subjects to subject set' do
        let(:subject_set_effect) do
          create :subject_rule_effect, action: 'add_subject_to_set', config: { 'subject_set_id': 777 }, subject_rule: rule
        end
        let(:subject_set_update_params) do
          {
            subject_rule_effect: { action: 'add_subject_to_set', config: { 'subject_set_id': 333 } },
            id: subject_set_effect.id,
            subject_rule_id: rule.id,
            workflow_id: workflow.id
          }
        end

        context 'when user does not have permission to that set' do
          before do
            allow_any_instance_of(SubjectRuleEffectPolicy).to receive(:update?).and_return(false)
          end

          it 'does not update a subject rule effect' do
            put :update, params: subject_set_update_params, format: :json
            expect(response.status).to eq(401)
          end

          it 'redirects to the edit path in html mode' do
            put :update, params: subject_set_update_params, format: :html
            expect(response).to redirect_to(
              edit_workflow_subject_rule_subject_rule_effect_path(subject_set_effect)
            )
          end

          it 'flashes an error message' do
            put :update, params: subject_set_update_params, format: :html
            msg = 'You do not have permission to update this subject rule effect for this project.'
            expect(flash[:alert]).to eq(msg)
          end
        end

        context 'when user has permission to that set' do
          before do
            allow_any_instance_of(SubjectRuleEffectPolicy).to receive(:update?).and_return(true)
          end

          it 'changes an effect' do
            put :update, params: subject_set_update_params, format: :json

            expect(response.status).to eq(204)
            updated_effect = SubjectRuleEffect.find(subject_set_effect.id)
            expect(updated_effect.config['subject_set_id']).to eq('333')
          end

          it 'redirects to the subject rule in html mode' do
            put :update, params: subject_set_update_params, format: :html
            expect(response).to redirect_to(edit_workflow_subject_rule_path(workflow, rule))
          end
        end
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

    describe '#edit' do
      it 'returns an effect for editing' do
        effect = create :subject_rule_effect, subject_rule: rule
        get :edit, params: { id: effect.id, subject_rule_id: rule.id, workflow_id: workflow.id }, format: :json
        result = JSON.parse(response.body)
        expect(result['id']).to eq(effect.id)
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
