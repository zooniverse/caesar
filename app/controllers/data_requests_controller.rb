class DataRequestsController < ApplicationController
  def create
    case params[:data_request][:requested_data]
    when "extracts"
      make_request(DataRequest.requested_data[:extracts])
    when "reductions"
      make_request(DataRequest.requested_data[:reductions])
    else
      head 404
    end
  end

  def show
    data_request = workflow.data_requests.find(params[:id])
    respond_with data_request
  end

  private

  def authorized?
    workflow.present?
  end

  def make_request(request_type)
    data_request = DataRequest.new(
      user_id: params[:user_id],
      workflow_id: workflow.id,
      subgroup: params[:subgroup],
      requested_data: request_type
    )

    data_request.status = DataRequest.statuses[:pending]
    data_request.url = nil
    data_request.save!

    DataRequestWorker.perform_async(data_request.workflow_id)
    respond_with workflow, data_request
  end

  def workflow
    @workflow ||= Workflow.accessible_by(credential).find(params[:workflow_id])
  end
end
