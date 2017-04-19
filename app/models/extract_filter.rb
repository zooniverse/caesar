class ExtractFilter
  attr_reader :extracts, :filters

  def initialize(extracts, filters)
    @extracts = extracts
    @filters = filters.with_indifferent_access
  end

  def to_a
    filter_by_extractor_ids(filter_by_subrange(extracts))
  end

  private

  def filter_by_subrange(extracts)
    group_extracts(extracts)[subrange].flat_map { |i| i[:data] }
  end

  def group_extracts(extracts)
    extracts
      .group_by(&:classification_id)
      .map { |k, v| {classification_id: k, data: v} }
      .sort_by { |hash| hash[:data][0].classification_at }
  end

  def filter_by_extractor_ids(extracts)
    return extracts if extractor_ids.blank?

    extracts.select { |extract| extractor_ids.include?(extract.extractor_id) }
  end

  def subrange
    from = filters["from"] || 0
    to   = filters["to"] || -1

    Range.new(from, to)
  end

  def extractor_ids
    filters["extractor_ids"] || []
  end
end
