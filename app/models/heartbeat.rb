class Heartbeat
  def initialize(workflow)
    @workflow = workflow
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

  def action_count
    SubjectAction.where(workflow_id: @workflow.id).count + UserAction.where(workflow_id: @workflow.id).count
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