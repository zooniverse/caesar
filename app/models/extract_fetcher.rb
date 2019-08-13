class ExtractFetcher < FetcherBase
  attr_reader :extract_ids, :strategy

  STRATEGIES = [ :fetch_all, :fetch_minimal ]

  def initialize(query, extract_ids)
    super(query)

    @extract_ids = extract_ids
    @strategy = :fetch_all
  end

  def strategy!(strategy)
    @strategy = strategy.to_sym
    self
  end

  def extracts
    if fetch_by_subject?
      subject_extracts
    elsif fetch_by_user?
      user_extracts
    else
      raise StandardError.new 'No fetch configured'
    end
  end

  def fetch_minimal?
    @strategy == :fetch_minimal
  end

  def user_extracts
    return Extract.none if query.fetch(:user_id, nil).blank?

    corrected_query = query.except(:subject_id)
    if fetch_minimal?
      Extract.where(corrected_query.merge(id: @extract_ids))
    else
      Extract.where(corrected_query)
    end
  end

  def subject_extracts
    corrected_query = query.except(:user_id)

    exact_subject_ids = Extract
      .find(@extract_ids)
      .pluck(:subject_id)
      .append(query[:subject_id])
      .uniq

    augmented_subject_ids = augment_subject_ids(exact_subject_ids)

    if fetch_minimal?
      get_minimal_subject_extracts(corrected_query, augmented_subject_ids, exact_subject_ids)
    else
      get_all_subject_extracts(corrected_query, augmented_subject_ids)
    end
  end

  def get_minimal_subject_extracts(query, augmented_subject_ids, exact_subject_ids)
    # is an extract exactly in the list of extracts with the specified subject
    # or is an extract for one of those prior subjects but not the specified subjects
    Extract.where(query.merge(id: @extract_ids))
      .or(Extract.where(
        query
          .except(:subject_id)
          .merge(subject_id: augmented_subject_ids-exact_subject_ids)
      )
    )
  end

  def get_all_subject_extracts(query, augmented_subject_ids)
    # is an extract for any of the subjects that were mentioned or any of their parents
    Extract.where(query.except(:subject_id).merge(subject_id: augmented_subject_ids))
  end

  def augment_subject_ids(id_list)
    additional_linked_subject_ids = id_list.map do |subject_id|
      Subject.find(subject_id).additional_subject_ids_for_reduction
    end
    (id_list + additional_linked_subject_ids.flatten).uniq
  end
end
