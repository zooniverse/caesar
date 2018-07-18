class UserRuleEffectsController < ApplicationController
  def index
    authorize workflow
    user_rule

    effects = policy_scope(UserRuleEffect).where(user_rule_id: params[:user_rule_id])
    render json: effects
  end

  def show
    authorize workflow
    user_rule

    @user_rule_effect = policy_scope(UserRuleEffect).find(params[:id]) or not found
    respond_with @user_rule_effect
  end

  def new
    authorize workflow
    @user_rule_effect = UserRuleEffect.new(action: params[:action_type], user_rule: user_rule)
    respond_with @user_rule_effect
  end

  def edit
    authorize workflow
    user_rule

    @user_rule_effect = UserRuleEffect.find(params[:id]) or not_found
  end

  def create
    authorize workflow
    user_rule

    @user_rule_effect = UserRuleEffect.new(effect_params)
    # @user_rule_effect.action = params[:user_rule_effect][:action] || params[:action_type]
    # @user_rule_effect.config = params[:config]

    if(@user_rule_effect.save)
      respond_to do |format|
        format.html{ redirect_to [:edit, workflow, user_rule] }
        format.json{ render json: @user_rule_effect }
      end
    else
      respond_with @user_rule_effect
    end
  end

  def update
    authorize workflow
    user_rule

    @user_rule_effect = UserRuleEffect.find(params[:id]) or not_found

    if(@user_rule_effect.update(effect_params))
      respond_to do |format|
        format.html{ redirect_to [:edit, workflow, user_rule] }
        format.json{ render json: @user_rule_effect }
      end
    else
      respond_with @user_rule_effect
    end
  end

  def destroy
    authorize workflow
    user_rule

    effect = UserRuleEffect.find(params[:id])

    effect.destroy
    respond_with effect, location: [:edit, workflow, user_rule]
  end

  private

  def workflow
    @workflow ||= policy_scope(Workflow).find(params[:workflow_id])
  end

  def user_rule
    @user_rule ||= UserRule.find(params[:user_rule_id])
  end

  def effect_params
    params.require(:user_rule_effect).permit(
      :action,
      :action_type,
      config: {}
    ).merge(user_rule_id: params[:user_rule_id])
  end
end

