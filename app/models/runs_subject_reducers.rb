class RunsSubjectReducers
    class ReductionConflict < StandardError; end
  
    attr_reader :reducible, :reducers
  
    def initialize(reducible, reducers)
      @reducible = reducible
      @reducers = reducers
    end
  
    def has_external?
      reducers.any?{ |reducer| reducer.type == 'Reducers::ExternalReducer' }
    end
  
    def reduce(subject_id, extract_ids = [])
      return [] unless reducers&.present?
      retries ||= 2
  
      extract_query = prepare_extract_query(subject_id)
      extracts = FetchExtractsBySubject.for(reducers).extracts(extract_query, extract_ids)

      reduction_filter = { reducible_id: reducible.id, reducible_type: reducible.class.to_s, subject_id: subject_id }
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
  
      new_reductions
    rescue ActiveRecord::StaleObjectError
      retry unless (retries-=1).zero?
      raise ReductionConflict, "Object version mismatch"
    rescue ActiveRecord::RecordNotUnique, PG::UniqueViolation
      retry unless (retries-=1).zero?
      raise ReductionConflict, "Transient uniqueness violation"
    end

    def relevant_reductions(extracts, reducer)
      user_ids = extracts.map(&:user_id)
      UserReduction.where(user_id: user_ids, reducible: reducible, reducer_key: reducer.user_reducer_keys)
    end
  
    def persist_reductions(reductions)
      ActiveRecord::Base.transaction do
        reductions.each do |reduction|
          reduction.save! unless (reduction.instance_of?(UserReduction) && reduction.user_id.nil?)
        end
      end
    end
  
    def prepare_extract_query(subject_id)
      { subject_id: subject_id }.tap do |extract_query|
        case reducible
        when Workflow
          extract_query[:workflow_id] = reducible.id
        when Project
          extract_query[:project_id] = reducible.id
        end
      end
    end
  end
  