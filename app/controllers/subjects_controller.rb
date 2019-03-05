class SubjectsController < ApplicationController
  def show
    skip_authorization
    @extracts = if workflow.nil?
      []
    else 
      workflow.extracts.where(subject_id: subject.id)
    end
    @reductions = (workflow||project).subject_reductions.where(subject_id: subject.id)
  end

  def search
    skip_authorization
    @workflow = workflow
    search_params = params.require(:search).permit(:id)
    subject_id = search_params[:id]

    if Subject.exists?(subject_id)
      redirect_to workflow_subject_path(workflow, subject_id) unless workflow.nil?
      redirect_to project_subject_path(project, subject_id) unless project.nil?
    else
      @subject = Subject.new(id: subject_id)
      render 'not_found'
    end
  end

  private

  def project
    @project ||= policy_scope(Project).find(params[:project_id]) if params.key? :project_id
  end

  def workflow
    @workflow ||= policy_scope(Workflow).find(params[:workflow_id]) if params.key? :workflow_id
  end

  def subject
    @subject ||= Subject.find(params[:id])
  end
end
