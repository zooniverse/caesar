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
    subject_reductions = RunsSubjectReducers.new(reducible, subject_reducers).reduce(subject_id, extract_ids)
    user_reductions = RunsUserReducers.new(reducible, user_reducers).reduce(user_id, extract_ids)
    new_reductions = subject_reductions + user_reductions

    if reducible.is_a?(Workflow) && and_check_rules && new_reductions.present?
      worker = CheckRulesWorker
      if reducible.custom_queue_name.present?
        worker.set(queue: reducible.custom_queue_name)
              .perform_async(reducible.id, reducible.class, subject_id, user_id)
      else
        worker.perform_async(reducible.id, reducible.class, subject_id, user_id)
      end
    end

    new_reductions
  end

  def subject_reducers
    reducers.select { |reducer| reducer.topic.to_sym == :reduce_by_subject}
  end

  def user_reducers
    reducers.select { |reducer| reducer.topic.to_sym == :reduce_by_user}
  end
end
