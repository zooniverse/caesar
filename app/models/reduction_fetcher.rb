class ReductionFetcher
  attr_accessor :topic
  def initialize(filter)
    @filter = filter
    @subject_reductions = SubjectReduction.where(filter.except(:user_id))
    @user_reductions = UserReduction.where(filter.except(:subject_id))

    @topic = :reduce_by_subject
  end

  def load!
    @subject_reductions.load
    @user_reductions.load
  end

  def for!(topic)
    @topic = topic.to_sym
    self
  end

  def retrieve(**kwargs)
    selector = @filter.merge(kwargs)
    return @subject_reductions.where(selector.except(:user_id)).first_or_initialize if reduce_by_subject?
    return @user_reductions.where(selector.except(:subject_id)).first_or_initialize if reduce_by_user?
  end

  def retrieve_in_place(**kwargs)
    selector = @filter.merge(kwargs)
    return locate_in_place(selector.except(:user_id), @subject_reductions, SubjectReduction) if reduce_by_subject?
    return locate_in_place(selector.except(:subject_id), @user_reductions, UserReduction) if reduce_by_user?
  end

  def reduce_by_user?
    @topic == :reduce_by_user
  end

  def reduce_by_subject?
    @topic == :reduce_by_subject
  end

  def locate_in_place(selector, relation, factory)
    match = relation.to_a.map(&:serializable_hash).select{ |record| key_match(record, selector) }
    match.empty? ? factory.new(selector) : match[0]
  end

  def key_match(record, selector)
    selector.all? { |key, value | record[key] == value }
  end
end