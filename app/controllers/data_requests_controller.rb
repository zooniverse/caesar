class DataRequestsController < ApplicationController
  def retrieve
  end

  def request_extracts
  end

  def request_reductions
  end

  def check_status
  end

  private

  def authorized?
    workflow.present?
  end

  def workflow
    @workflow ||= Workflow.accessible_by(credential).find(params[:workflow_id])
  end
end
