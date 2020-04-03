require 'spec_helper'

RSpec.describe SubjectRuleEffectsController, type: :controller do
  let(:workflow) { create :workflow }
  let(:rule) { create :subject_rule, workflow: workflow }

  context 'as a permissioned user'  do
    before{ fake_session admin: false, project_ids: [workflow.project_id], logged_in: true }

    # describe '#create', :focus do
    #   xit 'does not allow to create a new effect' do
    #     post :create, params: {subject_rule_effect: {action: 'retire_subject', config: {}}, workflow_id: workflow.id, subject_rule_id: rule.id }, format: :json

    #     expect(response.status).to eq(403)
    #     result = JSON.parse(response.body)
    #     binding.pry
    #     expect(result["id"]).not_to be(nil)
    #     expect(result["subject_rule_id"]).to eq(rule.id)
    #   end


    #   it 'makes a new effect', :focus do
    #     post :create, params: {subject_rule_effect: {action: 'retire_subject', config: {}}, workflow_id: workflow.id, subject_rule_id: rule.id }, format: :json

    #     expect(response.status).to eq(201)
    #     result = JSON.parse(response.body)
    #     expect(result["id"]).not_to be(nil)
    #     expect(result["subject_rule_id"]).to eq(rule.id)
    #   end

    #   it 'redirects to the subject rule in html mode' do
    #     post :create, params: {subject_rule_effect: {action: 'retire_subject', config: {}}, workflow_id: workflow.id, subject_rule_id: rule.id }, format: :html
    #     expect(response).to redirect_to(edit_workflow_subject_rule_path(workflow,rule))
    #   end
    # end

    # describe '#update', :focus do
    #   it 'does not allow the update and redirects to subject rule edit' do
    #     effect = create :subject_rule_effect, action: 'retire_subject', config: { foo: 'bar' }, subject_rule: rule
    #     put :update, params: { subject_rule_effect: { config: { foo: 'baz' }}, id: effect.id, subject_rule_id: rule.id, workflow_id: workflow.id }, format: :json

    #     expect(response.status).to eq(403)
    #     binding.pry
    #     effect = SubjectRuleEffect.find(effect.id)
    #     expect(effect.config['foo']).to eq('baz')
    #   end

    #   xit 'changes an effect' do
    #     effect = create :subject_rule_effect, action: 'retire_subject', config: { foo: 'bar' }, subject_rule: rule
    #     put :update, params: { subject_rule_effect: { config: { foo: 'baz' }}, id: effect.id, subject_rule_id: rule.id, workflow_id: workflow.id }, format: :json

    #     expect(response.status).to eq(204)
    #     effect = SubjectRuleEffect.find(effect.id)
    #     expect(effect.config['foo']).to eq('baz')
    #   end

    #   it 'redirects to the subject rule in html mode' do
    #     effect = create :subject_rule_effect, action: 'retire_subject', config: { foo: 'bar' }, subject_rule: rule
    #     put :update, params: { subject_rule_effect: { config: { foo: 'baz' }}, id: effect.id, subject_rule_id: rule.id, workflow_id: workflow.id }, format: :html
    #     expect(response).to redirect_to(edit_workflow_subject_rule_path(workflow,rule))
    #   end
    # end

    describe '#destroy' do
      it 'lets a user delete subject_rule_effects if they own the workflow' do
        sre2 = create :subject_rule_effect, subject_rule: rule
        response = delete :destroy, params: { id: sre2.id, workflow_id: workflow.id, subject_rule_id: rule.id }, format: :json

        expect(response.status).to eq(204)
        expect(SubjectRuleEffect.find_by_id(sre2.id)).to be(nil)
      end

      it 'does not let a user delete subject_rule_effects if they do not own the workflow' do
        other_workflow = create :workflow, project_id: workflow.project_id + 1
        other_rule = create :subject_rule, workflow: other_workflow
        sre2 = create :subject_rule_effect, subject_rule: other_rule
        response = delete :destroy, params: { id: sre2.id, workflow_id: other_workflow.id, subject_rule_id: other_rule.id }, format: :json

        expect(response.status).to eq(404)
        expect(SubjectRuleEffect.find_by_id(sre2.id)).not_to be(nil)
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
