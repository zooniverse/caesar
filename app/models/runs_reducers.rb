class RunsReducers
  class ReductionConflict < StandardError; end

  attr_reader :reducible, :reducers

  def initialize(reducible, reducers)
    @reducible = reducible
    @reducers = reducers
  end

  def reduce(subject_id, user_id, extract_ids=[])
    return [] unless reducers&.present?
    retries ||= 2

    prior_extracts = []
    if subject_id
      subject = Subject.find(subject_id)
      prior_subject_ids = subject.additional_subject_ids_for_reduction
      if prior_subject_ids.any?
        prior_extracts = Extract.where(subject_id: prior_subject_ids).pluck(:id)
      end
    end

    filter = { subject_id: subject_id, user_id: user_id }
    case reducible
    when Workflow
      filter[:workflow_id] = reducible.id
    when Project
      filter[:project_id] = reducible.id
    end

    extract_fetcher = ExtractFetcher.new(filter).including(extract_ids | prior_extracts)

    reduction_filter = { reducible_id: reducible.id, reducible_type: reducible.class.to_s, subject_id: subject_id, user_id: user_id }
    reduction_fetcher = ReductionFetcher.new(reduction_filter)

    # if we don't need to fetch everything, try not to
    if reducers.all?{ |reducer| reducer.running_reduction? }
      extract_fetcher.strategy! :fetch_minimal
    end

    # prefetch all reductions to avoid race conditions with optimistic locking
    if reducers.any?{ |reducer| reducer.running_reduction? }
      reduction_fetcher.load!
    end

    new_reductions = reducers.map do |reducer|
      reducer.process(extract_fetcher.for(reducer.topic), reduction_fetcher.for!(reducer.topic))
    end.flatten

    ActiveRecord::Base.transaction do
      new_reductions.each do |reduction|
        reduction.save!
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
end
