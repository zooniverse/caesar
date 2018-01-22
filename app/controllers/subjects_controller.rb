class SubjectsController < ApplicationController
  def show
    skip_authorization
    @extracts = workflow.extracts.where(subject_id: subject.id)
    @reductions = workflow.subject_reductions.where(subject_id: subject.id)
  end

  private

  def workflow
    @workflow ||= policy_scope(Workflow).find(params[:workflow_id])
  end

  def subject
    @subject ||= Subject.find(params[:id])
  end
end
