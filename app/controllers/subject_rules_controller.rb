class SubjectRulesController < ApplicationController
  def index
    authorize workflow

    rules = workflow.subject_rules
    respond_to do |format|
      format.html { redirect_to workflow }
      format.json { render json: rules }
    end
  end

  def show
    authorize workflow
    @subject_rule = workflow.subject_rules.find(params[:id])
    respond_with @subject_rule
  end

  def new
    authorize workflow
    @subject_rule = SubjectRule.new(workflow: workflow)
    respond_with @subject_rule
  end

  def edit
    authorize workflow
    @subject_rule = SubjectRule.find(params[:id])
  end

  def create
    authorize workflow

    @subject_rule = SubjectRule.new(rule_params)
    @subject_rule.save

    respond_to do |format|
      format.html{ redirect_to workflow }
      format.json{ render json: @subject_rule}
    end
  end

  def update
    authorize workflow
    @subject_rule = workflow.subject_rules.find(params[:id]) or not_found

    if @subject_rule.update(rule_params)
      respond_to do |format|
        format.html { redirect_to workflow, success: 'Rule updated' }
        format.json { render json: @subject_rule }
      end
    else
      respond_with @subject_rule
    end
  end

  def destroy
    authorize workflow
    rule = workflow.subject_rules.find(params[:id]) or not_found

    SubjectRule.transaction do
      SubjectRuleEffect.where(subject_rule_id: rule.id).delete_all
      rule.destroy
    end

    respond_with rule, location: [workflow]
  end

  private

  def workflow
    @workflow ||= policy_scope(Workflow).find(params[:workflow_id])
  end

  def rule_params
    p = params.require(:subject_rule).permit(:id)
    p.merge(condition: params[:subject_rule][:condition], workflow_id: workflow.id)
  end
end