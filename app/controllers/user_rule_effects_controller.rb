class UserRuleEffectsController < ApplicationController
  def index
    authorize workflow
    effects = policy_scope(UserRuleEffect).where(user_rule_id: params[:user_rule_id])
    render json: effects
  end

  def show
    authorize workflow
    @effect = policy_scope(UserRuleEffect).find(params[:id])
    respond_with @effect
  end

  def new
    authorize workflow
    @effect = UserRuleEffect.new(user_rule: user_rule)
  end

  def edit
    authorize workflow
    @effect = UserRule.find(id: params[:id])
  end

  def create
    authorize workflow

    @effect = UserRuleEffect.new(effect_params)
    @effect.save

    respond_to do |format|
      format.html { redirect_to [workflow, user_rule] }
      format.json { render json: @effect }
    end
  end

  def update
    authorize workflow
    @effect = UserRuleEffect.find(params[:id])

    if @effect.update(effect_params)
      respond_to do |format|
        format.html { redirect_to [workflow, user_rule] }
        format.json { render json: @effect }
      end
    else
      respond_with @effect
    end
  end

  def destroy
    authorize workflow
    effect = UserRuleEffect.find(params[:id])

    effect.destroy
    respond_with effect, location: [workflow]
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
      config: {}
    ).merge(user_rule_id: params[:user_rule_id])
  end
end

