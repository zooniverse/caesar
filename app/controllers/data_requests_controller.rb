class DataRequestsController < ApplicationController
  before_action :verify_exportable_resource
  responders :flash

  def index
    @workflow = workflow
    @project = project
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
    skip_authorization # operations do this themselves and raise if needed

    DataRequest.transaction do
      obj = nil
      args = params.fetch(:data_request, {})
        .merge(exportable_type: exportable_type)
        .merge(exportable_id: exportable_id)
      ctx = {credential: credential}

      data_request = CreatesDataRequests.call(obj, args, ctx)

      respond_to do |format|
        format.html { respond_with data_request, location: redirect_path }
        format.json { respond_with unscoped_exportable, data_request }
      end
    end
  rescue ArgumentError
    head 422
  end

  private

  def scope
    policy_scope(DataRequest).where(exportable_id: unscoped_exportable.id, exportable_type: unscoped_exportable.class.name)
  end

  def redirect_path
    return workflow_path(workflow, anchor: 'requests') if workflow.present?
    return project_path(project, anchor: 'requests') if project.present?
  end

  def path_exportable
    workflow || project
  end

  def unscoped_exportable
    unscoped_workflow || unscoped_project
  end

  def exportable_id
    params[:workflow_id] || params[:project_id]
  end

  def exportable_type
    if params.has_key? :workflow_id
      'Workflow'
    elsif params.has_key? :project_id
      'Project'
    else
      nil
    end
  end

  def verify_exportable_resource
    head 404 unless unscoped_exportable
  end

  def project
    @project ||= policy_scope(Project).find_by(id: params[:project_id])
  end

  def workflow
    @workflow ||= policy_scope(Workflow).find_by(id: params[:workflow_id])
  end

  def unscoped_workflow
    @unscoped_workflow ||= Workflow.find_by(id: params[:workflow_id])
  end

  def unscoped_project
    @unscoped_project ||= Project.find_by(id: params[:project_id])
  end
end
