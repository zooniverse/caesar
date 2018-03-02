class ExtractFetcher
  def initialize(workflow_id, subject_id, user_id, extract_ids=[])
    @workflow_id = workflow_id
    @subject_id = subject_id
    @user_id = user_id
    @extract_ids = extract_ids
  end

  def user_extracts
    @user_extracts ||= Extract.where(workflow_id: @workflow_id, user_id: @user_id).order(classification_at: :desc)
  end

  def subject_extracts
    @subject_extracts ||= Extract.where(workflow_id: @workflow_id, subject_id: @subject_id).order(classification_at: :desc)
  end

  def exact_extracts
    @exact_extracts ||= Extract.find(@extract_ids).order(classification_at: :desc)
  end
end
