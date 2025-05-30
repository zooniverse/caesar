class WorkflowsController < ApplicationController
  responders :flash

  def index
    @workflows = policy_scope(Workflow).all.sort_by(&:id)
    @workflow = Workflow.new
    respond_with @workflows
  end

  def show
    authorize workflow
    @paused_confirmation = 'Temporarily stops processing. When unpaused, workflow will pick up from where it left off. Use for temporary interruptions while editing configurations and/or fixing problems'
    @halt_confirmation = 'Halts processing and intake of classifications, equivalent to case where workflow does not exist on Caesar. When resumed, workflow will start processing classifications from that point forward, but all classifications submitted when halted are ignored. Use for long-term interruptions when Caesar should ignore incoming data.'
    @summary = WorkflowSummary.new(workflow)
    respond_with @workflow
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

    workflow_hash = credential.accessible_workflow?(params[:workflow][:id])

    unless workflow_hash.present?
      skip_authorization
      respond_to do |format|
        format.html { redirect_to workflows_path, :alert => 'Unable to add workflow' }
        format.json { head :forbidden }
      end
      return
    end

    if Workflow.where(id: workflow_id).exists?
      flash[:alert] = "Workflow already exists"
      redirect_to Workflow.find(workflow_id) and return
    end

    @workflow = Workflow.new(workflow_params.merge(
      id: workflow_id,
      project_id: workflow_hash["project_id"] || -1,
      name: workflow_hash["display_name"] || "New Workflow"
    ))

    @workflow.save

    DescribeWorkflowWorker.perform_async(@workflow.id) unless @workflow.id.blank?

    respond_to do |format|
      format.html { respond_with @workflow, location: workflows_path }
      format.json { render json: workflow }
    end
  end

  def update
    authorize workflow

    if params[:workflow][:rerun] == 'extractors'
      rerun_extractors
      respond_with workflow, location: workflow_path(workflow, anchor: 'extractors')
    elsif params[:workflow][:rerun] == 'reducers'
      rerun_reducers
      respond_with workflow, location: workflow_path(workflow, anchor: 'reducers')
    else
      was_paused = workflow.paused?
      was_halted = workflow.halted?

      workflow.update(workflow_params)

      if workflow.active?
        flash[:notice] = 'Resuming workflow' if was_paused || was_halted
        UnpauseWorkflowWorker.perform_async(workflow.id) if was_paused
      end

      if !was_paused && workflow.paused?
        flash[:notice] = 'Pausing workflow'
      end

      if !was_halted && workflow.halted?
        flash[:notice] = 'Halting workflow'
      end

      Workflow::ConvertLegacyExtractorsConfig.new(workflow).update(params[:workflow][:extractors_config])
      Workflow::ConvertLegacyReducersConfig.new(workflow).update(params[:workflow][:reducers_config])
      Workflow::ConvertLegacyRulesConfig.new(workflow).update(params[:workflow][:rules_config])
      respond_with workflow, location: workflow_path(workflow, anchor: 'settings')
    end
  end

  private

  def workflow
    @workflow ||= policy_scope(Workflow).find(params[:id])
  end

  def rerun_extractors
    workflow.rerun_extractors
    flash[:notice] = "Re-running extractors. Results may take some time to process."
  end

  def rerun_reducers
    workflow.rerun_reducers
    flash[:notice] = "Re-running reducers. Results may take some time to process."
  end

  def workflow_params
    params.require(:workflow).permit(
      :public_extracts,
      :public_reductions,
      :status,
      :rules_applied,
      :rerun,
    )
  end
end
