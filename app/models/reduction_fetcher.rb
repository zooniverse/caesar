class ReductionFetcher
  attr_reader :loaded

  def initialize(query)
    super(query)
    @loaded = false

    @subject_reductions = SubjectReduction.where(query.except(:user_id))
    @user_reductions = UserReduction.where(query.except(:subject_id))

    @topic = :fetch_by_subject
  end

  def load!
    @subject_reductions.load
    @user_reductions.load
    @loaded = true
  end

  def search(**kwargs)
    selector = query.merge(kwargs)
    selector.delete(:user_id) if fetch_by_subject?
    selector.delete(:subject_id) if fetch_by_user?

    if loaded
      locate_in_place(selector, source_relation)
    else
      source_relation.where(selector).first_or_initialize.to_a
    end
  end

  def source_relation
    if fetch_by_subject?
      @subject_reductions
    elsif fetch_by_user?
      @user_reductions
    else
      raise NotImplementedError 'This topic is not supported'
    end
  end

  def locate_in_place(selector, relation)
    relation.to_a.select{ |record| key_match(record, selector) }
  end

  def key_match(record, selector)
    selector.all? { |key, value | record[key] == value }
  end
end