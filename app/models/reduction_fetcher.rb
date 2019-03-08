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

  def retrieve(reducer_key, subgroup, in_place: false)
    where(@filter.merge(reducer_key: reducer_key, subgroup: subgroup), in_place: in_place)
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

  def where(selector, in_place: false)
    if in_place
      return locate_in_place(selector.except(:user_id), @subject_reductions, SubjectReduction) if reduce_by_subject?
      return locate_in_place(selector.except(:subject_id), @user_reductions, UserReduction) if reduce_by_user?
    else
      return @subject_reductions.where(selector.except(:user_id)).first_or_initialize if reduce_by_subject?
      return @user_reductions.where(selector.except(:subject_id)).first_or_initialize if reduce_by_user?
    end
  end

  def locate_in_place(selector, relation, factory)
    match = relation.to_a.map(&:serializable_hash).select{ |record| key_match(record, selector) }
    match.empty? ? factory.new(selector) : match[0]
  end

  def key_match(record, selector)
    selector.all? { |key, _ | record[key] == selector[key]}
  end
end