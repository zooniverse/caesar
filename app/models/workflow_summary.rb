class WorkflowSummary
  def initialize(workflow)
    @workflow = workflow
  end

  def extracts_count
    @workflow.extracts_count || 0
  end

  def reductions_count
    subject_reductions + user_reductions
  end

  def actions_count
    subject_actions + user_actions
  end

  def subject_reductions
    @workflow.subject_reductions_count || 0
  end

  def user_reductions
    @workflow.user_reductions_count || 0
  end

  def subject_actions
    @workflow.subject_actions_count || 0
  end

  def user_actions
    @workflow.user_actions_count || 0
  end

  def last_extract
    @workflow.extracts.order(updated_at: :desc).first&.updated_at
  end

  def last_reduction
    [
      @workflow.subject_reductions.order(updated_at: :desc).first&.updated_at,
      @workflow.user_reductions.order(updated_at: :desc).first&.updated_at,
    ].compact.max
  end

  def last_action
    [
      SubjectAction.where(workflow_id: @workflow.id).order(updated_at: :desc).first&.updated_at,
      UserAction.where(workflow_id: @workflow.id).order(updated_at: :desc).first&.updated_at
    ].compact.max
  end

  def subject_count
    return @subject_count if @subject_count

    ids = []
    ids.concat(@workflow.extracts.pluck(:id).uniq)
    ids.concat(@workflow.subject_reductions.pluck(:id).uniq)
    ids.concat(@workflow.user_reductions.pluck(:id).uniq)

    @subject_count = ids.uniq.count
  end
end