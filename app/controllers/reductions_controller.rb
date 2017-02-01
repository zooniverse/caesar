class ReductionsController < ApplicationController
  before_action :authenticate!

  def index
    reductions = Reduction.where(workflow_id: params[:workflow_id], subject_id: params[:subject_id])
    render json: reductions
  end

  def update
    reduction = Reduction.find_or_initialize_by(workflow_id: workflow.id,
                                                reducer_id: reducer.id,
                                                subject_id: subject.id)
    reduction.update! reduction_params

    render json: reduction
  end

  private

  def authenticate!
    if request_signature_valid?
      true
    else
      head :forbidden
    end
  end

  def request_signature_valid?
    Rails.env.development? || Rails.env.test?
  end

  def workflow
    @workflow ||= Workflow.find(params[:workflow_id])
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
