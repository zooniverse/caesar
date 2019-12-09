class FetchExtractsBySubject < FetcherBase
  def extracts(query, extract_ids)
    subject_extracts_query = query.except(:user_id)

    subject_ids_from_specified_extracts = Extract.where(id: extract_ids).pluck(:subject_id)
    exact_subject_ids = subject_ids_from_specified_extracts | query[:subject_id]
    augmented_subject_ids = augment_subject_ids(exact_subject_ids)

    case @strategy
    when :fetch_minimal
      @minimal_subject_extracts ||= get_minimal_subject_extracts(subject_extracts_query, extract_ids, augmented_subject_ids, exact_subject_ids)
    else
      @all_subject_extracts ||= get_all_subject_extracts(subject_extracts_query, augmented_subject_ids)
    end
  end

  def get_minimal_subject_extracts(query, extract_ids, augmented_subject_ids, exact_subject_ids)
    # is an extract exactly in the list of extracts with the specified subject
    # or is an extract for one of those prior subjects but not the specified subjects
    Extract.where(query.merge(id: extract_ids))
      .or(Extract.where(
        query
          .except(:subject_id)
          .merge(subject_id: augmented_subject_ids - exact_subject_ids)
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
