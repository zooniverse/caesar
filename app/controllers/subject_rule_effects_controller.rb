class SubjectRuleEffectsController < ApplicationController
  responders :flash

  def index
    # using the WorkflowPolicy for 'authorize workflow' here, not the SubjectRuleEffectPolicy
    authorize workflow
    effects = policy_scope(SubjectRuleEffect).where(subject_rule_id: params[:subject_rule_id])
    respond_with effects
  end

  def show
    # TODO: Add this to the SubjectRuleEffect policy class
    # and pass in the found subject_rule_effect
    authorize workflow
    @subject_rule_effect = policy_scope(SubjectRuleEffect).find(params[:id])
    respond_with workflow, subject_rule, @subject_rule_effect
  end

  def new
    # using the WorkflowPolicy for 'authorize workflow' here, not the SubjectRuleEffectPolicy
    authorize workflow, :edit?
    @subject_rule_effect = SubjectRuleEffect.new(action: params[:action_type], subject_rule: subject_rule)
    respond_with workflow, subject_rule, @subject_rule_effect
  end

  def edit
    # TODO: the finders for SubjectRuleEffect in this controller
    # are ripe for a preload / eager_load as we'll use the
    # subject_rule.workflow relation in the policy scopes
    @subject_rule_effect = SubjectRuleEffect.eager_load(:subject_rule).find(params[:id])
    authorize @subject_rule_effect

    respond_with workflow, subject_rule, @subject_rule_effect
  end

  def create
    # using the WorkflowPolicy for 'authorize workflow' here, not the SubjectRuleEffectPolicy
    authorize workflow, :edit?

    @subject_rule_effect = SubjectRuleEffect.new(effect_params)
    # using the SubjectRuleEffectPolicy here
    authorize @subject_rule_effect
    @subject_rule_effect.save

    respond_to do |format|
      format.html { respond_with workflow, subject_rule, @subject_rule_effect, location: edit_workflow_subject_rule_path(workflow, subject_rule) }
      format.json { respond_with workflow, subject_rule, @subject_rule_effect }
    end
  rescue Pundit::NotAuthorizedError
    respond_to do |format|
      format.html do
        flash[:alert] = 'You do not have permission to create this effect. Please confirm that you have permissions to the associated workflow, subject set or collection.'
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
        flash[:alert] = 'You do not have permission to make this change. Please confirm that you have permissions to the associated subject set or collection.'
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
end
