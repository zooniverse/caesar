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
    @user_rule = workflow.user_rules.find(params[:id]) or not_found
    respond_with @user_rule
  end

  def new
    authorize workflow
    @user_rule = UserRule.new(workflow: workflow)
  end

  def edit
    authorize workflow
    @user_rule = UserRule.find(params[:id]) or not_found
  end

  def create
    authorize workflow

    @user_rule = UserRule.new(rule_params)
    @user_rule.save

    respond_to do |format|
      format.html{ respond_with @user_rule, location: workflow_path(workflow, :anchor => "rules") }
      format.json{ render json: @user_rule}
    end
  end

  def update
    authorize workflow

    @user_rule = workflow.user_rules.find(params[:id]) or not_found
    @user_rule.update(rule_params)

    respond_to do |format|
      format.html{ respond_with @user_rule, location: workflow_path(workflow, :anchor => "rules") }
      format.json { render json: @user_rule }
    end
  end

  def destroy
    authorize workflow
    rule = workflow.user_rules.find(params[:id])

    UserRule.transaction do
      UserRuleEffect.where(user_rule_id: rule.id).delete_all
      rule.destroy
    end

    rule.destroy
    respond_with rule, location: workflow_path(workflow, :anchor => "rules)")
  end

  private

  def workflow
    @workflow ||= policy_scope(Workflow).find(params[:workflow_id])
  end

  def rule_params
    p = params.require(:user_rule).permit(:condition, :condition_string, :id)
    p.merge(condition: JSON.parse(p["condition_string"] || p["condition"]), workflow_id: workflow.id).
      except("condition_string")
  end
end
