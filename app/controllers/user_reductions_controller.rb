class UserReductionsController < ApplicationController
  def index
    reductions = policy_scope(UserReduction).where(workflow_id: params[:workflow_id], user_id: params[:user_id])
    reductions = reductions.where(reducer_key: params[:reducer_key]) if params.key?(:reducer_key)

    render json: reductions
  end

  def update
    reduction = UserReduction.find_or_initialize_by(reducible_id: workflow.id,
                                                reducible_type: "Workflow",
                                                reducer_key: reducer.key,
                                                user_id: user_id,
                                                subgroup: subgroup)
    authorize reduction

    if reduction.data != reduction_params[:data]
      reduction.update! reduction_params
      CheckRulesWorker.perform_async(workflow.id, "Workflow", user_id) if workflow.configured?
      workflow.webhooks.process(:updated_reduction, data) if workflow.subscribers?
    end

    render json: reduction
  end

  private

  def workflow
    @workflow ||= policy_scope(Workflow).find(params[:workflow_id])
  end

  def data
    params[:reduction][:data]
  end

  def subgroup
    params[:reduction][:subgroup] || :_default
  end

  def reducer
    workflow.reducers.find_by!(key: params[:reducer_key])
  end

  def user_id
    @user_id ||= params[:reduction][:user_id]
  end

  def reduction_params
    params.require(:reduction).permit(:data).tap do |whitelisted|
      whitelisted[:data] = params[:reduction][:data].permit!
    end
  end
end
