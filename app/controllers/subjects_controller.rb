class SubjectsController < ApplicationController
  def show
    skip_authorization
    @extracts = if workflow.nil?
      []
    else
      workflow.extracts.where(subject_id: subject.id)
    end
    @reductions = reducible.subject_reductions.where(subject_id: subject.id)
  end

  def search
    skip_authorization
    @workflow = workflow
    search_params = params.require(:search).permit(:id)
    subject_id = search_params[:id]

    if Subject.exists?(subject_id)
      if workflow
        redirect_to workflow_subject_path(workflow, subject_id)
      elsif project
        redirect_to project_subject_path(project, subject_id)
      else
        # should this raise if there isn't a workflow or project and subject exists?
      end
    else
      @subject = Subject.new(id: subject_id)
      render 'not_found'
    end
  end

  private

  def reducible
    if params.has_key? :workflow_id
      workflow
    elsif params.has_key? :project_id
      project
    else
        # should this raise if there isn't a workflow or project and subject exists?
    end
  end

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
