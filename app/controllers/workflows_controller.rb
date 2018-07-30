class WorkflowsController < ApplicationController
  def index
    @workflows = policy_scope(Workflow).all.sort_by(&:id)
    @workflow = Workflow.new
    respond_with @workflows
  end

  def show
    authorize workflow
    @heartbeat = {
      :extract => workflow.extracts.first&.updated_at,
      :reduction => [
        workflow.subject_reductions.order(updated_at: :desc).first&.updated_at,
        workflow.user_reductions.order(updated_at: :desc).first&.updated_at
      ].compact.max,
      :action => [
        SubjectAction.where(workflow_id: workflow.id).order(updated_at: :desc).first&.updated_at,
        UserAction.where(workflow_id: workflow.id).order(updated_at: :desc).first&.updated_at
      ].compact.max,
      :action_count => SubjectAction.where(workflow_id: workflow.id).count + UserAction.where(workflow_id: workflow.id).count
    }
    respond_with workflow
  end

  def new
    skip_authorization

    unless params[:id].present?
      head :bad_request
      return
    end

    if workflow = Workflow.accessible_by(credential).find_by(id: params[:id])
      redirect_to workflow
      return
    end

    workflow_hash = credential.accessible_workflow?(params[:id])

    if workflow_hash.present?
      @workflow = Workflow.new(id: params[:id], project_id: workflow_hash["links"]["project"])
    else
      head :not_found
    end
  end

  def create
    skip_authorization
    workflow_id = params[:workflow][:id]

    workflow_hash = { id: workflow_id }
    workflow_hash = credential.accessible_workflow?(params[:workflow][:id]) unless Rails.env.development?

    unless workflow_hash.present?
      skip_authorization
      head :forbidden
      return
    end

    panoptes_workflow = Effects.panoptes.workflow(workflow_id) unless Rails.env.development?
    if Rails.env.development?
      panoptes_workflow = { workflow_id: workflow_id, project_id: workflow_id, display_name: 'New Workflow'}.stringify_keys
    end

    @workflow = Workflow.new(workflow_params.merge(
      id: workflow_id,
      project_id: panoptes_workflow["project_id"],
      name: panoptes_workflow["display_name"]
    ))

    begin
      if @workflow.save
        flash[:success] = "Added workflow \"#{@workflow.name}\""
        DescribeWorkflowWorker.perform_async(@workflow.id)
        respond_with @workflow
      else
        flash[:error] = 'Failed to add workflow'
        redirect_to workflows_path
      end
    rescue
      flash[:error] = 'Failed to add workflow'
      redirect_to workflows_path
    end
  end

  def update
    authorize workflow

    workflow.update!(workflow_params)

    Workflow::ConvertLegacyExtractorsConfig.new(workflow).update(params[:workflow][:extractors_config])
    Workflow::ConvertLegacyReducersConfig.new(workflow).update(params[:workflow][:reducers_config])
    Workflow::ConvertLegacyRulesConfig.new(workflow).update(params[:workflow][:rules_config])

    respond_with workflow
  end

  private

  def workflow
    @workflow ||= policy_scope(Workflow).find(params[:id])
  end

  def workflow_params
    params.require(:workflow).permit(
      :public_extracts,
      :public_reductions,
      :rules_applied,
      webhooks_config: {},
    )
  end
end
