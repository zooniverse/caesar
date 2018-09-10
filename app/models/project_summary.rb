class ProjectSummary
  def initialize(project)
    @project = project
  end

  def reductions_count
    subject_reductions + user_reductions
  end

  def subject_reductions
    @project.subject_reductions_count || 0
  end

  def user_reductions
    @project.user_reductions_count || 0
  end

  def last_reduction
    [
      @project.subject_reductions.order(updated_at: :desc).first&.updated_at,
      @project.user_reductions.order(updated_at: :desc).first&.updated_at,
    ].compact.max
  end
end