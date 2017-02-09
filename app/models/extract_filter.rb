class ExtractFilter
  attr_reader :extracts, :filters

  def initialize(extracts, filters)
    @extracts = extracts
    @filters = filters.with_indifferent_access
  end

  def to_a
    filter_extracts(extracts)
  end

  private

  def filter_extracts(extracts)
    group_extracts(extracts)[subrange].flat_map { |i| i[:data] }
  end

  def group_extracts(extracts)
    extracts
      .group_by(&:classification_id)
      .map{ |k,v| { :classification_id => k, :data => v } }
      .sort_by{ |hash| hash[:data][0].classification_at }
  end

  def subrange
    from = filters["from"] || 0
    to   = filters["to"] || -1

    Range.new(from, to)
  end
end
