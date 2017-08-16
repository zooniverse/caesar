class ReductionsController < ApplicationController
  def index
    reductions = policy_scope(Reduction).where(workflow_id: params[:workflow_id], subject_id: params[:subject_id])
    reductions = reductions.where(reducer_key: params[:reducer_key]) if params.key?(:reducer_key)

    render json: reductions
  end

  def update
    reduction = Reduction.find_or_initialize_by(workflow_id: workflow.id,
                                                reducer_key: reducer.key,
                                                subject_id: subject.id)
    authorize reduction
    reduction.update! reduction_params

    CheckRulesWorker.perform_async(workflow.id, subject.id) if workflow.configured?

    workflow.webhooks.process(:updated_reduction, data) if workflow.subscribers?

    render json: reduction
  end

  private

  def authorized?
    workflow.present?
  end

  def workflow
    @workflow ||= Workflow.accessible_by(credential).find(params[:workflow_id])
  end

  def data
    params[:reduction][:data]
  end

  def reducer
    workflow.reducers[params[:reducer_key]]
  end

  def subject
    @subject ||= Subject.find(params[:reduction][:subject_id])
  end

  def reduction_params
    params.require(:reduction).permit(:data).tap do |whitelisted|
      whitelisted[:data] = params[:reduction][:data].permit!
    end
  end
end
