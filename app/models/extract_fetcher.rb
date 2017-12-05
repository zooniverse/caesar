class ExtractFetcher
  def initialize(workflow_id, subject_id, user_id)
    @workflow_id = workflow_id
    @subject_id = subject_id
    @user_id = user_id
  end

  def user_extracts
    @user_extracts ||= Extract.where(workflow_id: @workflow_id, user_id: @user_id).order(classification_at: :desc)
  end

  def subject_extracts
    @subject_extracts ||= Extract.where(workflow_id: @workflow_id, subject_id: @subject_id).order(classification_at: :desc)
  end
end
