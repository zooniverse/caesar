class DataRequestsController < ApplicationController
  def index
    @data_requests = scope.order(created_at: :desc)
    respond_with @data_requests
  end

  def show
    data_request = scope.find(params[:id])
    authorize data_request
    respond_with data_request
  end

  def create
    data_request = params[:data_request] || {}
    requested_data = data_request[:requested_data] || nil

    case requested_data
    when "extracts"
      make_request(DataRequest.requested_data[:extracts])
    when "reductions"
      make_request(DataRequest.requested_data[:reductions])
    else
      skip_authorization
      head 422
    end
  end

  private

  def make_request(request_type)
    data_request = DataRequest.new(
      user_id: params[:user_id],
      workflow_id: params[:workflow_id],
      subgroup: params[:subgroup],
      requested_data: request_type
    )
    authorize data_request

    data_request.status = DataRequest.statuses[:pending]
    data_request.url = nil
    data_request.save!

    DataRequestWorker.perform_async(data_request.id)
    respond_to do |format|
      format.html { redirect_to [data_request.workflow, :data_requests] }
      format.json { respond_with data_request.workflow, data_request }
    end
  end

  def scope
    policy_scope(DataRequest).where(workflow_id: params[:workflow_id])
  end
end
