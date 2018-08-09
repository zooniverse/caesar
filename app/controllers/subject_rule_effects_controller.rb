class SubjectRuleEffectsController < ApplicationController
  def index
    authorize workflow
    effects = policy_scope(SubjectRuleEffect).where(subject_rule_id: params[:subject_rule_id])
    render json: effects
  end

  def show
    authorize workflow
    @effect = policy_scope(SubjectRuleEffect).find(params[:id])
    respond_with @effect
  end

  def new
    authorize workflow
    @effect = SubjectRuleEffect.new(subject_rule: subject_rule)
  end

  def edit
    authorize workflow
    @effect = SubjectRule.find(id: params[:id])
  end

  def create
    authorize workflow

    @effect = SubjectRuleEffect.new(effect_params)
    if @effect.save
      respond_to do |format|
        format.html { redirect_to [workflow, subject_rule] }
        format.json { render json: @effect }
      end
    else
      respond_with @effect
    end
  end

  def update
    authorize workflow
    @effect = SubjectRuleEffect.find(params[:id])

    if @effect.update(effect_params)
      respond_to do |format|
        format.html { redirect_to [workflow, subject_rule] }
        format.json { render json: @effect }
      end
    else
      respond_with @effect
    end
  end

  def destroy
    authorize workflow
    effect = SubjectRuleEffect.find(params[:id])

    effect.destroy
    respond_with effect, location: [workflow, subject_rule]
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
      config: {}
    ).merge(subject_rule_id: params[:subject_rule_id])
  end
end
