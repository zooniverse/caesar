class SubjectsController < ApplicationController
  def show
    skip_authorization
    @extracts = workflow.extracts.where(subject_id: subject.id)
    @reductions = workflow.subject_reductions.where(subject_id: subject.id)
  end

  def search
    skip_authorization
    @workflow = workflow
    search_params = params.require(:search).permit(:id)
    subject_id = search_params[:id]

    if Subject.exists?(subject_id)
      @subject = Subject.find(subject_id) || Subject.new
      @extracts = workflow.extracts.where(subject_id: subject_id)
      @reductions = workflow.subject_reductions.where(subject_id: subject_id)

      render 'show'
    else
      @subject = Subject.new(id: subject_id)
      render 'not_found'
    end
  end

  private

  def workflow
    @workflow ||= policy_scope(Workflow).find(params[:workflow_id])
  end

  def subject
    @subject ||= Subject.find(params[:id])
  end
end
