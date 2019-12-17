class RunsUserReducers
  class ReductionConflict < StandardError; end

  attr_reader :reducible, :reducers

  def initialize(reducible, reducers)
    @reducible = reducible
    @reducers = reducers
  end

  def has_external?
    reducers.any?{ |reducer| reducer.type == 'Reducers::ExternalReducer' }
  end

  def reduce(user_id, extract_ids=[], and_check_rules: false)
    return [] unless reducers&.present?
    return [] unless user_id
    retries ||= 2

    extract_query = prepare_extract_query(user_id)
    extracts = FetchExtractsByUser.for(reducers).extracts(extract_query, extract_ids)

    reduction_filter = { reducible_id: reducible.id, reducible_type: reducible.class.to_s, user_id: user_id }
    reduction_fetcher = ReductionFetcher.new(reduction_filter)

    # prefetch all reductions to avoid race conditions with optimistic locking
    if reducers.any?{ |reducer| reducer.running_reduction? }
      reduction_fetcher.load!
    end

    new_reductions = reducers.map do |reducer|
      reducer.process(
        extracts, 
        reduction_fetcher.for!(reducer.topic), 
        relevant_reductions(extracts, reducer)
      )
    end.flatten

    persist_reductions(new_reductions)

    if reducible.is_a?(Workflow) && and_check_rules && new_reductions.present?
      check_rules(CheckUserRulesWorker, user_id)
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
        reduction.save! unless reduction.user_id.nil?
      end
    end
  end
  
  def relevant_reductions(extracts, reducer)
    subject_ids = extracts.map(&:subject_id)
    SubjectReduction.where(subject_id: subject_ids, reducible: reducible, reducer_key: reducer.subject_reducer_keys)
  end

  def prepare_extract_query(user_id)
    { user_id: user_id }.tap do |extract_query|
      case reducible
      when Workflow
        extract_query[:workflow_id] = reducible.id
      when Project
        extract_query[:project_id] = reducible.id
      end
    end
  end

  def check_rules(worker, user_id)
    if reducible.custom_queue_name.present?
      worker.set(queue: reducible.custom_queue_name)
            .perform_async(reducible.id, reducible.class, user_id)
    else
      worker.perform_async(reducible.id, reducible.class, user_id)
    end
  end
end
