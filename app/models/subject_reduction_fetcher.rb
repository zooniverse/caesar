class SubjectReductionFetcher
  attr_accessor :topic
  def initialize(filter)
    @filter = filter
    @subject_reductions = SubjectReduction.where(filter)
  end

  def load!
    @subject_reductions.load
  end

  def retrieve(**kwargs)
    selector = @filter.merge(kwargs)
    @subject_reductions.where(selector).first_or_initialize
  end

  def retrieve_in_place(**kwargs)
    selector = @filter.merge(kwargs)
    locate_in_place(selector, @subject_reductions, SubjectReduction)
  end

  def locate_in_place(selector, relation, factory)
    match = relation.to_a.select{ |record| key_match(record, selector) }
    match.empty? ? factory.new(selector) : match[0]
  end

  def key_match(record, selector)
    selector.all? { |key, value | record[key] == value }
  end
end