class ProjectExtractFetcher
  def initialize(project_id, subject_id, user_id)
    @project_id = project_id
    @subject_id = subject_id
    @user_id = user_id
  end

  def user_extracts
    @user_extracts ||= Extract.where(workflow_id: @workflow_ids, user_id: @user_id).order(classification_at: :desc)

  end

  def subject_extracts
    @subject_extracts ||= Extract.where(workflow_id: @workflow_ids, subject_id: @subject_id).order(classification_at: :desc)
  end

  private

  def project
    @project ||= Project.find(@project_id)
  end

  def workflow_ids
    @workflow_ids ||= @project.workflows.ids
  end
end
