class ExtractsForClassification
  def self.from(extracts)
    extracts \
      .sort_by(&:classification_at)
      .group_by(&:classification_id)
      .map { |_, group| new(group) }
  end

  attr_reader :extracts

  def initialize(extracts)
    @extracts = extracts
  end

  def empty?
    extracts.empty?
  end

  def select(&block)
    self.class.new(extracts.select(&block))
  end

  def reject(&block)
    self.class.new(extracts.reject(&block))
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

  def subject_id
    extracts.first.subject_id
  end
end
