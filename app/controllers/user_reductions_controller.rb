class UserReductionsController < ApplicationController
  def index
    reductions = policy_scope(UserReduction).where(reducible_id: reducible.id, user_id: params[:user_id])
    reductions = reductions.where(reducer_key: params[:reducer_key]) if params.key?(:reducer_key)

    render json: reductions
  end

  def update
    reduction = UserReduction.find_or_initialize_by(reducible_id: reducible.id,
                                                reducible_type: reducible_type,
                                                reducer_key: reducer.key,
                                                user_id: user_id,
                                                subgroup: subgroup)
    authorize reduction

    if reduction.data != reduction_params[:data]
      reduction.update! reduction_params
      CheckRulesWorker.perform_async(reducible.id, reducible_type, user_id) if workflow.configured?
    end

    render json: reduction
  end

  def current_user_reductions
    reducible_type = params[:reducible_type].titleize.singularize
    reducible_id = params[:reducible_id]

    reductions = UserReduction.where(
      user_id: credential.current_user_id,
      reducible_type: reducible_type,
      reducible_id: reducible_id
    )

    authorize reductions
    render json: reductions
  end

  private

  def reducible
    @reducible ||=  if params[:workflow_id]
                      policy_scope(Workflow).find(params[:workflow_id])
                    elsif params[:project_id]
                      policy_scope(Project).find(params[:project_id])
                    end
  end

  def reducible_type
    @reducible_type ||= if params[:workflow_id]
                          "Workflow"
                        elsif params[:project_id]
                          "Project"
                        end
  end

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
