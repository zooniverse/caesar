class FetchExtractsByUser < FetcherBase
  def extracts(query, extract_ids)
    return Extract.none if query.fetch(:user_id, nil).blank?

    user_extracts_query = query.except(:subject_id)

    case @strategy
    when :fetch_minimal
      Extract.where(user_extracts_query.merge(id: extract_ids))
    else
      Extract.where(user_extracts_query)
    end
  end
end
