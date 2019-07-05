class RunsReducers
  class ReductionConflict < StandardError; end

  attr_reader :reducible, :reducers

  def initialize(reducible, reducers)
    @reducible = reducible
    @reducers = reducers
  end

  def reduce(subject_id, user_id, extract_ids=[], and_check_rules: false)
    return [] unless reducers&.present?
    retries ||= 2

    filter = { subject_id: subject_id, user_id: user_id }
    case reducible
    when Workflow
      filter[:workflow_id] = reducible.id
    when Project
      filter[:project_id] = reducible.id
    end

    extract_fetcher = ExtractFetcher.new(filter, extract_ids)
    reduction_filter = { reducible_id: reducible.id, reducible_type: reducible.class.to_s, subject_id: subject_id, user_id: user_id }
    reduction_fetcher = ReductionFetcher.new(reduction_filter)

    # prefetch all reductions to avoid race conditions with optimistic locking
    if reducers.any?{ |reducer| reducer.running_reduction? }
      reduction_fetcher.load!
    end

    new_reductions = reducers.map do |reducer|
      fetcher = extract_fetcher.for(reducer.topic)

      relevant_reductions = case reducer.topic
                            when 0, "reduce_by_subject"
                              user_ids = fetcher.extracts.map(&:user_id)
                              UserReduction.where(user_id: user_ids, reducible: reducible, reducer_key: reducer.user_reducer_keys)
                            when 1, "reduce_by_user"
                              subject_ids = fetcher.extracts.map(&:subject_id)
                              SubjectReduction.where(subject_id: subject_ids, reducible: reducible, reducer_key: reducer.subject_reducer_keys)
                            end
      reducer.process(fetcher, reduction_fetcher.for!(reducer.topic), relevant_reductions)
    end.flatten

    persist_reductions(new_reductions)

    if reducible.is_a?(Workflow) && and_check_rules
      CheckRulesWorker.perform_async(reducible.id, reducible.class, subject_id, user_id) unless new_reductions.blank?
    end

    new_reductions
  rescue ActiveRecord::StaleObjectError
    retry unless (retries-=1).zero?
    raise ReductionConflict, "Object version mismatch"
  rescue ActiveRecord::RecordNotUnique, PG::UniqueViolation
    retry unless (retries-=1).zero?
    raise ReductionConflict, "Transient uniqueness violation"
  end

  def persist_reductions(reductions)
    ActiveRecord::Base.transaction do
      reductions.each do |reduction|
        reduction.save! unless (reduction.instance_of?(UserReduction) && reduction.user_id.nil?)
      end
    end
  end
end
