class ReductionFetcher
  attr_accessor :topic
  def initialize(keys)
    @keys = keys
    @subject_reductions = SubjectReduction.where(keys.except(:user_id))
    @user_reductions = UserReduction.where(keys.except(:subject_id))

    @topic = :reduce_by_subject
  end

  def load
    @subject_reductions.load
    @user_reductions.load
  end

  def for(topic)
    @topic = topic.to_sym
    self
  end

  def subgroup(subgroup)
    where(@keys.merge(subgroup: subgroup))
  end

  def reductions
    return @subject_reductions if reduce_by_subject?
    return @user_reductions if reduce_by_user?
  end

  def reduce_by_user?
    @topic == :reduce_by_user
  end

  def reduce_by_subject?
    @topic == :reduce_by_subject
  end

  def where(query)
    return @subject_reductions.where(query.except(:user_id)) if reduce_by_subject?
    return @user_reductions.where(query.except(:subject_id)) if reduce_by_user?
  end

  def have_expired?
    has_expired?
  end

  def has_expired?
    true if (reduce_by_subject? && @subject_reductions.any?{ |reduction| reduction.expired? })
    true if (reduce_by_user? && @user_reductions.any?{ |reduction| reduction.expired? })
    false
  end
end