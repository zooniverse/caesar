class RunsReducers
  class ReductionConflict < StandardError; end

  attr_reader :reducible, :reducers

  def initialize(reducible, reducers)
    @reducible = reducible
    @reducers = reducers
  end

  def has_external?
    reducers.any?{ |reducer| reducer.type == 'Reducers::ExternalReducer' }
  end

  def reduce(subject_id, user_id, extract_ids=[], and_check_rules: false)
    RunsSubjectReducers.new(reducible, subject_reducers).reduce(subject_id, extract_ids, and_check_rules: and_check_rules)
    RunsUserReducers.new(reducible, user_reducers).reduce(user_id, extract_ids, and_check_rules: and_check_rules)
  end

  def subject_reducers
    reducers.select { |reducer| reducer.topic.to_sym == :reduce_by_subject}
  end

  def user_reducers
    reducers.select { |reducer| reducer.topic.to_sym == :reduce_by_user}
  end
end
