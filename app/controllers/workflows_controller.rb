class WorkflowsController < ApplicationController
  def show
    respond_with workflow
  end

  def update
    workflow.update!(workflow_params)
    respond_with workflow
  end

  private

  def workflow
    @workflow ||= Workflow.accessible_by(credential).find(params[:id])
  end

  def workflow_params
    params.require(:workflow).permit(
      extractors_config: {},
      reducers_config: {},
      rules_config: {}
    )
  end
end
