class SubjectsController < ApplicationController
  def show
    @extracts = Extract.where(workflow_id: workflow.id, subject_id: subject.id)
    @reductions = Reduction.where(workflow_id: workflow.id, subject_id: subject.id)
  end

  private

  def workflow
    @workflow ||= Workflow.accessible_by(credential).find(params[:workflow_id])
  end

  def subject
    @subject ||= Subject.find(params[:id])
  end
end
