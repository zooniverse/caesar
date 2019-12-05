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

    filter = { subject_id: subject_id, user_id: user_id }
    case reducible
    when Workflow
      filter[:workflow_id] = reducible.id
    when Project
      filter[:project_id] = reducible.id
    end

    extract_query = prepare_extract_query(subject_id, user_id)
    reduction_filter = { reducible_id: reducible.id, reducible_type: reducible.class.to_s, subject_id: subject_id, user_id: user_id }
    reduction_fetcher = ReductionFetcher.new(reduction_filter)

    # prefetch all reductions to avoid race conditions with optimistic locking
    if reducers.any?{ |reducer| reducer.running_reduction? }
      reduction_fetcher.load!
    end

    # if all of the reducers are configured in running mode, then we should
    # set :fetch_minimal as early as possible so that trying to find relevant
    # reductions doesn't require us to fetch all extracts
    if reducers.all?{ |reducer| reducer.running_reduction? }
      extract_fetcher.strategy! :fetch_minimal
    end

    new_reductions = reducers.map do |reducer|
      next UserReduction.none if (reducer.reduce_by_user? && user_id.nil?)

      extract_fetcher = reducer.extract_fetcher
      extracts = extract_fetcher.extracts(extract_query, extract_ids)

      relevant_reductions = case reducer.topic
                            when 0, "reduce_by_subject"
                              user_ids = extracts.map(&:user_id)
                              UserReduction.where(user_id: user_ids, reducible: reducible, reducer_key: reducer.user_reducer_keys)
                            when 1, "reduce_by_user"
                              subject_ids = extracts.map(&:subject_id)
                              SubjectReduction.where(subject_id: subject_ids, reducible: reducible, reducer_key: reducer.subject_reducer_keys)
                            end
      reducer.process(extracts, reduction_fetcher.for!(reducer.topic), relevant_reductions)
    end.flatten

    persist_reductions(new_reductions)

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
end
