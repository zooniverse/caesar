class ExtractFetcher
  attr_accessor :reduction_mode, :topic, :extract_ids, :strategy
  attr_reader :filter

  STRATEGIES = [ :fetch_all, :fetch_minimal ]

  def initialize(filter, extract_ids)
    @filter = filter

    @extract_ids = extract_ids
    @topic = :reduce_by_subject
    @strategy = :fetch_all
  end

  def strategy!(strategy)
    @strategy = strategy.to_sym
    self
  end

  def for(topic)
    @topic = topic.to_sym
    self
  end

  def extracts
    if fetch_subjects?
      subject_extracts
    elsif fetch_users?
      user_extracts
    else
      raise StandardError.new 'No fetch configured'
    end
  end

  def fetch_minimal?
    @strategy == :fetch_minimal
  end

  def fetch_users?
    @topic == :reduce_by_user
  end

  def fetch_subjects?
    @topic == :reduce_by_subject
  end

  def user_extracts
    corrected_filter = filter.except(:subject_id)
    if fetch_minimal?
      Extract.where(corrected_filter.merge(id: @extract_ids))
    else
      Extract.where(corrected_filter)
    end
  end

  def subject_extracts
    corrected_filter = filter.except(:user_id)

    exact_subject_ids = Extract
      .find(@extract_ids)
      .pluck(:subject_id)
      .append(filter[:subject_id])
      .uniq

    augmented_subject_ids = augment_subject_ids(exact_subject_ids)

    if fetch_minimal?
      get_minimal_subject_extracts(corrected_filter, augmented_subject_ids, exact_subject_ids)
    else
      get_all_subject_extracts(corrected_filter, augmented_subject_ids)
    end
  end

  def get_minimal_subject_extracts(filter, augmented_subject_ids, exact_subject_ids)
    # is an extract exactly in the list of extracts with the specified subject
    # or is an extract for one of those prior subjects but not the specified subjects
    Extract.where(filter.merge(id: @extract_ids))
      .or(Extract.where(
        filter
          .except(:subject_id)
          .merge(subject_id: augmented_subject_ids-exact_subject_ids)
      )
    )
  end

  def get_all_subject_extracts(filter, augmented_subject_ids)
    # is an extract for any of the subjects that were mentioned or any of their parents
    Extract.where(filter.except(:subject_id).merge(subject_id: augmented_subject_ids))
  end

  def augment_subject_ids(id_list)
    additional_linked_subject_ids = id_list.map do |subject_id|
      Subject.find(subject_id).additional_subject_ids_for_reduction
    end
    (id_list + additional_linked_subject_ids.flatten).uniq
  end
end
