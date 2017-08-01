class DataRequestsController < ApplicationController
  def request_extracts
    make_request(DataRequest::EXTRACTS)
  end

  def request_reductions
    make_request(DataRequest::REDUCTIONS)
  end

  def check_status
    request = DataRequest.find(params[:request_id])
    return head 404 if request.blank?

    case request.status
    when DataRequest::PENDING
      head 201
    when DataRequest::PROCESSING
      head 202
    when DataRequest::FAILED
      head 500
    when DataRequest::COMPLETE
      head 200
    end
  end

  def retrieve
    request = DataRequest.find(params[:request_id])
    return head 404 if request.blank? || request.url.blank?

    render json: request.url
  end

  private

  def authorized?
    workflow.present?
  end

  def make_request(request_type)
    request = DataRequest.find_or_initialize_by(
      user_id: params[:user_id],
      workflow_id: params[:workflow_id],
      subgroup: params[:subgroup],
      requested_data: request_type
    )

    case request.status
    when DataRequest::EMPTY, DataRequest::FAILED, DataRequest::COMPLETE
      # set the job to pending status, save it, and kick off a worker to process it
      request.status = DataRequest::PENDING
      request.url = ''
      request.save

      DataRequestWorker.perform_async(request.workflow_id)
      render json: request
    when DataRequest::PENDING, DataRequest::PROCESSING
      # we already know about this request and are working on it
      head 429
    end
  end

  def workflow
    @workflow ||= Workflow.accessible_by(credential).find(params[:workflow_id])
  end
end
