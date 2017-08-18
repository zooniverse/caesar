class ReductionsController < ApplicationController
  def index
    reductions = Reduction.where(workflow_id: params[:workflow_id], subject_id: params[:subject_id])
    reductions = reductions.where(reducer_id: params[:reducer_id]) if params.key?(:reducer_id)

    render json: reductions
  end

  def update
    reduction = Reduction.find_or_initialize_by(workflow_id: workflow.id,
                                                reducer_id: reducer.id,
                                                subject_id: subject.id)
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
    workflow.reducers[params[:reducer_id]]
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
