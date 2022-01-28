class SubjectRuleEffectsController < ApplicationController
  responders :flash

  def index
    authorize workflow, policy_class: SubjectRuleEffectPolicy
    effects = policy_scope(SubjectRuleEffect).where(subject_rule_id: params[:subject_rule_id])
    respond_with effects
  end

  def show
    authorize workflow, policy_class: SubjectRuleEffectPolicy
    @subject_rule_effect = policy_scope(SubjectRuleEffect).find(params[:id])
    respond_with workflow, subject_rule, @subject_rule_effect
  end

  def new
    authorize workflow, policy_class: SubjectRuleEffectPolicy
    @subject_rule_effect = SubjectRuleEffect.new(action: params[:action_type], subject_rule: subject_rule)
    respond_with workflow, subject_rule, @subject_rule_effect
  end

  def edit
    @subject_rule_effect = SubjectRuleEffect.includes(subject_rule: [:workflow]).find(params[:id])
    authorize @subject_rule_effect

    respond_with workflow, subject_rule, @subject_rule_effect
  end

  def create
    @subject_rule_effect = SubjectRuleEffect.new(effect_params)
    authorize @subject_rule_effect

    respond_to do |format|
      if @subject_rule_effect.save
        format.json { render json: @subject_rule_effect }
      else
        format.json { render json: json_error_messages(@subject_rule_effect.errors), status: :unprocessable_entity }
      end
      format.html { respond_with workflow, subject_rule, @subject_rule_effect, location: edit_workflow_subject_rule_path(workflow, subject_rule) }
    end
  rescue Pundit::NotAuthorizedError
    respond_to do |format|
      format.html do
        flash[:alert] = 'You do not have permission to create this subject rule effect. Please check project collaborator status and subject set or collection IDs.'
        redirect_to new_workflow_subject_rule_subject_rule_effect_path(
          action_type: effect_params[:action]
        )
      end
      format.json { raise(Pundit::NotAuthorizedError) }
    end
  end

  def update
    @subject_rule_effect = SubjectRuleEffect.find(params[:id])
    authorize @subject_rule_effect

    @subject_rule_effect.update(effect_params)

    respond_to do |format|
      format.html { respond_with workflow, subject_rule, @subject_rule_effect, location: edit_workflow_subject_rule_path(workflow, subject_rule) }
      format.json { respond_with workflow, subject_rule, @subject_rule_effect }
    end
  rescue Pundit::NotAuthorizedError
    respond_to do |format|
      format.html do
        flash[:alert] = 'You do not have permission to update this subject rule effect. Please check project collaborator status and subject set or collection IDs.'
        redirect_to edit_workflow_subject_rule_subject_rule_effect_path(@subject_rule_effect)
      end
      format.json { raise(Pundit::NotAuthorizedError) }
    end
  end

  def destroy
    subject_rule_effect = SubjectRuleEffect.find(params[:id])
    authorize subject_rule_effect

    subject_rule_effect.destroy

    respond_with(
      subject_rule_effect,
      location: edit_workflow_subject_rule_path(workflow, subject_rule)
    )
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

  def record_not_valid(exception)
    render json: { error: exception.message }, status: 422
  end
end
