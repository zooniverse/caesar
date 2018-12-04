class RunsReducers
  class ReductionConflict < StandardError; end

  attr_reader :reducible_class, :reducers

  def initialize(reducible_class, reducers)
    @reducible_class = reducible_class
    @reducers = reducers
  end

  def reduce(reducible_id, subject_id, user_id, extract_ids=[])
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
    if reducible_class.to_s == "Workflow"
      filter[:workflow_id] = reducible_id
    elsif reducible_class.to_s == "Project"
      filter[:project_id] = reducible_id
    end

    extract_fetcher = ExtractFetcher.new(filter).including(extract_ids | prior_extracts)

    reduction_filter = { reducible_id: reducible_id, reducible_type: reducible_class.to_s, subject_id: subject_id, user_id: user_id }
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
