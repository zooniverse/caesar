class ReductionFetcher
  def initialize(workflow_id, subject_id, user_id)
    @workflow_id = workflow_id
    @subject_id = subject_id
    @user_id = user_id
  end

  def user_reductions
    [] if @user_id.blank?
    @user_reductions ||= Reduction.where(workflow_id: @workflow_id, user_id: @user_id).order(updated_at: :desc)
  end

  def subject_reductions
    [] if @subject_id.blank?
    @subject_reductions ||= Reduction.where(workflow_id: @workflow_id, subject_id: @subject_id).order(updated_at: :desc)
  end
end
