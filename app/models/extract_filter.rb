class ExtractFilter
  include ActiveModel::Validations

  REPEATED_CLASSIFICATIONS = ["keep_first", "keep_last", "keep_all"]
  EMPTY_EXTRACTS = ["keep_all", "ignore_empty"]

  validates :repeated_classifications, inclusion: {in: REPEATED_CLASSIFICATIONS}
  validates :empty_extracts, inclusion: {in: EMPTY_EXTRACTS}
  validates :from, numericality: true
  validates :to, numericality: true

  attr_reader :filters

  def initialize(filters)
    @filters = filters.with_indifferent_access
  end

  def filter(extracts)
    extracts = ExtractsForClassification.from(extracts)
    filter_by_subrange(filter_by_emptyness(filter_by_extractor_keys(filter_by_repeatedness(extracts)))).flat_map(&:extracts)
  end

  private

  def filter_by_repeatedness(extracts)
    case repeated_classifications
    when "keep_all"
      extracts
    when "keep_first"
      keep_first_classification(extracts)
    when "keep_last"
      keep_first_classification(extracts.reverse).reverse
    end
  end

  def filter_by_subrange(extracts)
    extracts.select do |extract_group|
      extract_group.extracts.length > 0
    end.sort_by(&:classification_at)[subrange]
  end

  def filter_by_extractor_keys(extracts)
    return extracts if extractor_keys.blank?

    extracts.map do |group|
      group.select do |extract|
        extractor_keys.include?(extract.extractor_key)
      end
    end
  end

  def filter_by_emptyness(extracts)
    case empty_extracts
    when "keep_all"
      extracts
    when "ignore_empty"
      extracts.map do |extract_group|
        extract_group.select { |extract| extract.data.present? }
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

  def from
    filters["from"].to_i || 0
  end

  def to
    filters["to"].to_i || -1
  end

  def subrange
    Range.new(from, to)
  end

  def extractor_keys
    Array.wrap(filters["extractor_keys"]) || []
  end

  def repeated_classifications
    filters["repeated_classifications"] || "keep_first"
  end

  def empty_extracts
    filters["empty_extracts"] || "keep_all"
  end
end
