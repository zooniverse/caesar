class DataRequestsController < ApplicationController
  def index
    @data_requests = workflow.data_requests.order(created_at: :desc)
    respond_with @data_requests
  end

  def show
    data_request = workflow.data_requests.find(params[:id])
    authorize data_request
    respond_with data_request
  end

  def create
    skip_authorization

    data_request = params[:data_request] || {}
    requested_data = data_request[:requested_data] || nil

    case requested_data
    when "extracts"
      make_request(DataRequest.requested_data[:extracts])
    when "reductions"
      make_request(DataRequest.requested_data[:reductions])
    else
      head 422
    end
  end

  private

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

    DataRequestWorker.perform_async(data_request.id)
    respond_to do |format|
      format.html { redirect_to [workflow, :data_requests] }
      format.json { respond_with workflow, data_request }
    end
  end

  def workflow
    @workflow ||= policy_scope(Workflow).find(params[:workflow_id])
  end
end
