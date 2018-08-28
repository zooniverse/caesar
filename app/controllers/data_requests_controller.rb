class DataRequestsController < ApplicationController
  responders :flash

  def index
    @workflow = workflow
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

      data_request = CreatesDataRequests.call(obj, args, ctx)
      skip_authorization # operations do this themselves and raise if needed

      respond_to do |format|
        format.html { respond_with data_request, location: workflow_path(workflow, anchor: 'requests') }
        format.json { respond_with unscoped_workflow, data_request }
      end
    end
  end

  private

  def scope
    policy_scope(DataRequest).where(workflow_id: params[:workflow_id])
  end

  def workflow
    @workflow ||= policy_scope(Workflow).find(params[:workflow_id])
  end

  def unscoped_workflow
    @unscoped_workflow ||= Workflow.find(params[:workflow_id])
  end
end
