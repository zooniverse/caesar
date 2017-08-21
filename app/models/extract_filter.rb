class ExtractFilter
  class ExtractsForClassification
    attr_reader :extracts

    def initialize(extracts)
      @extracts = extracts
    end

    def select(&block)
      self.class.new(extracts.select(&block))
    end

    def classification_id
      extracts.first.classification_id
    end

    def classification_at
      extracts.first.classification_at
    end

    def user_id
      extracts.first.user_id
    end
  end

  attr_reader :extracts, :filters

  def initialize(extracts, filters)
    @extracts = extracts.group_by(&:classification_id).map { |_, group| ExtractsForClassification.new(group) }
    @filters = filters.with_indifferent_access
  end

  def to_a
    filter_by_extractor_keys(filter_by_subrange(filter_by_repeatedness(extracts))).flat_map(&:extracts)
  end

  private

  def filter_by_repeatedness(extracts)
    case @filters[:repeated_classifications] || "keep_first"
    when "keep_all"
      extracts
    when "keep_first"
      keep_first_classification(extracts)
    when "keep_last"
      keep_first_classification(extracts.reverse).reverse
    end
  end

  def filter_by_subrange(extracts)
    extracts.sort_by(&:classification_at)[subrange]
  end

  def filter_by_extractor_keys(extracts)
    return extracts if extractor_keys.blank?

    extracts.map do |group|
      group.select do |extract|
        extractor_keys.include?(extract.extractor_key)
      end
    end
  end

  def keep_first_classification(extracts)
    user_ids ||= Set.new

    extracts.select do |extracts_for_classification|
      next true unless extracts_for_classification.user_id
      next false if user_ids.include?(extracts_for_classification.user_id)
      user_ids << extracts_for_classification.user_id
      true
    end.to_a
  end

  def subrange
    from = filters["from"] || 0
    to   = filters["to"] || -1

    Range.new(from, to)
  end

  def extractor_keys
    filters["extractor_keys"] || []
  end
end
