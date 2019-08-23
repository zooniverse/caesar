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
    return [] unless reducers&.present?
    retries ||= 2

    extract_fetcher = ExtractFetcher.new(prepare_extract_query(subject_id, user_id), extract_ids)
    reduction_fetcher = ReductionFetcher.new(prepare_reduction_query(subject_id, user_id))

    # prefetch all reductions to avoid race conditions with optimistic locking
    if reducers.any?{ |reducer| reducer.running_reduction? }
      reduction_fetcher.load!
    end

    new_reductions = reducers.map do |reducer|
      next UserReduction.none if (reducer.reduce_by_user? && user_id.nil?)

      extract_fetcher.for! reducer.topic

      if reducer.running_reduction?
        extract_fetcher.strategy! :fetch_minimal
      else
        extract_fetcher.strategy! :fetch_all
      end

      extracts = extract_fetcher.extracts

      # Set relevant reduction on each extract if required by external reducer
      # relevant_reductions are any previously reduced user or subject reductions
      # that are required by this reducer to properly calculate
      reducer.augment_extracts(extracts.to_a)

      reductions = reduction_fetcher.for!(reducer.topic).search(reducer_key: reducer.key)

      reducer.process(extracts, reductions, subject_id, user_id)
    end.flatten

    persist_reductions(new_reductions)

    if reducible.is_a?(Workflow) && and_check_rules && new_reductions.present? && (not reducible.halted?)
      worker = CheckRulesWorker
      worker.set(queue: reducible.custom_queue_name) if reducible.custom_queue_name.present?
      worker.perform_async(reducible.id, reducible.class, subject_id, user_id)
    end

    new_reductions
  rescue ActiveRecord::StaleObjectError
    retry unless (retries-=1).zero?
    raise ReductionConflict, "Object version mismatch"
  rescue ActiveRecord::RecordNotUnique, PG::UniqueViolation
    retry unless (retries-=1).zero?
    raise ReductionConflict, "Transient uniqueness violation"
  end

  def prepare_extract_query(subject_id, user_id)
    { subject_id: subject_id, user_id: user_id }.tap do |extract_query|
      case reducible
      when Workflow
        extract_query[:workflow_id] = reducible.id
      when Project
        extract_query[:project_id] = reducible.id
      end
    end
  end

  def prepare_reduction_query(subject_id, user_id)
    { reducible_id: reducible.id, reducible_type: reducible.class.to_s, subject_id: subject_id, user_id: user_id }
  end

  def persist_reductions(reductions)
    ActiveRecord::Base.transaction do
      reductions.each do |reduction|
        # never save user reductions with no user id because that doesn't make sense
        reduction.save! unless (reduction.instance_of?(UserReduction) && reduction.user_id.nil?)
      end
    end
  end
end
