class DataRequestsController < ApplicationController
  def index
    @workflow = Workflow.find(params[:workflow_id])
    @data_requests = scope.order(created_at: :desc)

    if(params.has_key?(:subgroup))
      @data_requests = @data_requests.where(subgroup: params[:subgroup])
    end

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
      args = ({requested_data: params.dig(:data_request, :requested_data)} || {}).merge(workflow_id: params[:workflow_id])
      ctx = {credential: credential}

      begin
        data_request = CreatesDataRequests.call(obj, args, ctx)
        skip_authorization # operations do this themselves and raise if needed
        flash[:success] = 'Export requested'

        respond_to do |format|
          format.html { redirect_to workflow_path(Workflow.find(data_request.workflow_id), anchor: 'requests') }
          format.json { respond_with Workflow.find(data_request.workflow_id), data_request }
        end
      rescue
        flash[:error] = 'Failed to request export'
        redirect_to workflow_path(Workflow.find(data_request.workflow_id), anchor: 'requests')
      end
    end
  end

  private

  def scope
    policy_scope(DataRequest).where(workflow_id: params[:workflow_id])
  end
end
