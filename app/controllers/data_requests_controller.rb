class DataRequestsController < ApplicationController
  def request_extracts
    make_request(DataRequest.requested_data[:extracts])
  end

  def request_reductions
    make_request(DataRequest.requested_data[:reductions])
  end

  def check_status
    request = DataRequest.find(params[:request_id])
    return head 404 if request.nil?

    if request.pending?
      return head 201
    end

    if request.processing?
      return head 202
    end

    if request.failed?
      return head 500
    end

    if request.complete?
      return head 200
    end

  end

  def retrieve
    request = DataRequest.find(params[:request_id])
    return head 404 if request.nil? or request.url.blank?

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

    if request.empty? or request.failed? or request.complete?
      request.status = DataRequest.statuses[:pending]
      request.url = nil
      request.save!

      DataRequestWorker.perform_async(request.workflow_id)
      return render json: request
    end

    if request.pending? or request.processing?
      return head 429
    end

  end

  def workflow
    @workflow ||= Workflow.accessible_by(credential).find(params[:workflow_id])
  end
end
