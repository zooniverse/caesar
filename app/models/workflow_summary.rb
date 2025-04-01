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

  def stoplight_status
    {
      failed_extractors: collection_selector(@workflow.extractors),
      failed_reducers: collection_selector(@workflow.reducers),
      failed_subject_rules: collection_selector(@workflow.subject_rules),
      failed_user_rules: collection_selector(@workflow.user_rules)
    }
  end

  private

  def collection_selector(collection, status = Stoplight::Color::RED)
    collection.select { |collection_item| collection_item.stoplight_color == status }
  end
end