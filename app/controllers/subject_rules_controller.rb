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
    @rule = workflow.subject_rules.find(params[:id])
    respond_with @rule
  end

  def new
    authorize workflow
    @rule = SubjectRule.new(workflow: workflow)
  end

  def edit
    authorize workflow
    @rule = SubjectRule.find(id: params[:id])
  end

  def create
    authorize workflow

    @rule = SubjectRule.new(rule_params)
    @rule.save

    respond_to do |format|
      format.html{ redirect_to workflow }
      format.json{ render json: @rule}
    end
  end

  def update
    authorize workflow
    @rule = workflow.subject_rules.find(params[:id]) or not_found

    if @rule.update(rule_params)
      respond_to do |format|
        format.html { redirect_to workflow, success: 'Rule updated' }
        format.json { render json: @rule }
      end
    else
      respond_with @rule
    end
  end

  def destroy
    authorize workflow
    rule = workflow.subject_rules.find(params[:id])

    rule.destroy
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