class FetchExtractsBySubject < FetcherBase
  def extracts(query, extract_ids)
    subject_extracts_query = query.except(:user_id)

    subject_ids_from_specified_extracts = Extract.where(id: extract_ids).pluck(:subject_id)
    exact_subject_ids = subject_ids_from_specified_extracts | Array.wrap(query[:subject_id])
    exact_and_additional_subject_ids = exact_and_additional_subject_ids(exact_subject_ids)

    case @strategy
    when :fetch_minimal
      get_minimal_subject_extracts(
        subject_extracts_query, 
        extract_ids, 
        additional_subject_ids(exact_subject_ids)
      )
    else
      get_all_subject_extracts(subject_extracts_query, exact_and_additional_subject_ids)
    end
  end

  def get_minimal_subject_extracts(query, extract_ids, exact_and_additional_subject_ids, exact_subject_ids)
    # is an extract exactly in the list of extracts with the specified subject
    requested_extracts = query.merge(id: extract_ids)
    # or is an extract for one of those prior subjects but not the specified subjects
    previous_subject_extracts = query.except(:subject_id).merge(subject_id: exact_and_additional_subject_ids - exact_subject_ids)

    Extract.where(requested_extracts).or(Extract.where(previous_subject_extracts))
  end

  def get_all_subject_extracts(query, exact_and_additional_subject_ids)
    # is an extract for any of the subjects that were mentioned or any of their parents
    all_subject_extracts = query.except(:subject_id).merge(subject_id: exact_and_additional_subject_ids)
    Extract.where(all_subject_extracts)
  end

  def exact_and_additional_subject_ids(subject_ids)
    subject_ids | additional_subject_ids(subject_ids)
  end

  def additional_subject_ids(subject_ids)
    Subject.where(id: subject_ids).map(&:additional_subject_ids_for_reduction).flatten.uniq
  end
end
