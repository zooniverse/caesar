class SubjectRuleEffectsController < ApplicationController
  def index
    authorize workflow
    subject_rule
    effects = policy_scope(SubjectRuleEffect).where(subject_rule_id: params[:subject_rule_id])
    render json: effects
  end

  def show
    authorize workflow
    subject_rule
    @subject_rule_effect = policy_scope(SubjectRuleEffect).find(params[:id]) or not found
    respond_with @subject_rule_effect
  end

  def new
    authorize workflow
    @subject_rule_effect = SubjectRuleEffect.new(action: params[:action_type], subject_rule: subject_rule)
    respond_with @subject_rule_effect
  end

  def edit
    authorize workflow
    subject_rule
    @subject_rule_effect = SubjectRuleEffect.find(params[:id]) or not_found
  end

  def create
    authorize workflow
    subject_rule

    @subject_rule_effect = SubjectRuleEffect.new(effect_params)

    if(@subject_rule_effect.save)
      respond_to do |format|
        format.html{ redirect_to [:edit, workflow, subject_rule] }
        format.json{ render json: @subject_rule_effect }
      end
    else
      respond_with @subject_rule_effect
    end
  end

  def update
    authorize workflow
    subject_rule

    @subject_rule_effect = SubjectRuleEffect.find(params[:id]) or not_found

    if(@subject_rule_effect.update(effect_params))
      respond_to do |format|
        format.html{ redirect_to [:edit, workflow, subject_rule] }
        format.json{ render json: @subject_rule_effect }
      end
    else
      respond_with @subject_rule_effect
    end
  end

  def destroy
    authorize workflow
    subject_rule

    effect = SubjectRuleEffect.find(params[:id])

    effect.destroy
    respond_with effect, location: [:edit, workflow, subject_rule]
  end

  private

  def workflow
    @workflow ||= policy_scope(Workflow).find(params[:workflow_id])
  end

  def subject_rule
    @subject_rule ||= SubjectRule.find(params[:subject_rule_id])
  end

  def effect_params
    params.require(:subject_rule_effect).permit(
      :action,
      :action_type,
      config: {}
    ).merge(subject_rule_id: params[:subject_rule_id])
  end
end
