class UserRulesController < ApplicationController
  responders :flash

  def index
    authorize workflow

    rules = UserRule.where(workflow_id: params[:workflow_id])
    respond_to do |format|
      format.html { redirect_to workflow }
      format.json { render json: rules }
    end
  end

  def show
    authorize workflow
    @user_rule = workflow.user_rules.find(params[:id])
    respond_with @user_rule
  end

  def new
    authorize workflow, :edit?
    @user_rule = UserRule.new(workflow: workflow)
  end

  def edit
    authorize workflow
    @user_rule = UserRule.find(params[:id])
    respond_with @user_rule
  end

  def create
    authorize workflow, :edit?

    @user_rule = UserRule.new(rule_params)
    @user_rule.save

    respond_to do |format|
      format.html { respond_with @user_rule, location: workflow_path(workflow, :anchor => "rules") }
      format.json { render json: @user_rule}
    end
  end

  def update
    authorize workflow

    @user_rule = workflow.user_rules.find(params[:id])
    @user_rule.update(rule_params)

    respond_to do |format|
      format.html{ respond_with workflow, @user_rule, location: workflow_path(workflow, :anchor => "rules") }
      format.json { render json: @user_rule }
    end
  end

  def destroy
    authorize workflow, :edit?

    rule = workflow.user_rules.find(params[:id])
    rule.destroy

    respond_with rule, location: workflow_path(workflow, :anchor => "rules)")
  end

  private

  def workflow
    @workflow ||= policy_scope(Workflow).find(params[:workflow_id])
  end

  def rule_params
    if params.dig :user_rule, :condition
      params.require(:user_rule).permit(:id).merge(condition: params.require(:user_rule).require(:condition))
    elsif params.dig :user_rule, :condition_string
      params.require(:user_rule).permit(:id).merge(condition: JSON.parse(params[:user_rule][:condition_string]))
    else
      raise StandardError.new('No condition specified')
    end.merge(workflow_id: workflow.id)
  end
end
