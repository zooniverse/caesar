class SubjectsController < ApplicationController
  def index
    @extracts = policy_scope(Extract)
                  .where(workflow_id: params[:workflow_id])
                  .includes(:subject)
                  .order(updated_at: :desc)
                  .limit(12)
  end

  def show
    skip_authorization
    @extracts = workflow.extracts.where(subject_id: subject.id)
    @reductions = workflow.reductions.where(subject_id: subject.id)
    @actions = workflow.actions.where(subject_id: subject.id)
  end

  private

  def workflow
    @workflow ||= policy_scope(Workflow).find(params[:workflow_id])
  end

  def subject
    @subject ||= Subject.find(params[:id])
  end
end
