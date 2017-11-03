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
    DataRequest.transaction do
      obj = nil
      args = (params[:data_request] || {}).merge(workflow_id: params[:workflow_id])
      ctx = {credential: credential}

      data_request = CreatesDataRequests.call(obj, args, ctx)
      authorize data_request

      respond_to do |format|
        format.html { redirect_to [data_request.workflow, :data_requests] }
        format.json { respond_with data_request.workflow, data_request }
      end
    end
  end

  private

  def scope
    policy_scope(DataRequest).where(workflow_id: params[:workflow_id])
  end
end
