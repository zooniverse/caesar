class ExtractFilter
  include ActiveModel::Validations

  REPEATED_CLASSIFICATIONS = ["keep_first", "keep_last", "keep_all"]
  EMPTY_EXTRACTS = ["keep_all", "ignore_empty"]
  TRAINING_BEHAVIOR = ["ignore_training", "training_only", "experiment_only"]

  def valid?
    filter_objects.map{ |filter| filter.valid? }.all?
  end

  attr_reader :filters

  def initialize(filters)
    @filters = filters.with_indifferent_access
  end

  def filter(extracts)
    @extracts = extracts
    apply_filters(extract_groups, filter_objects)
  end

  private

  def foo
    false
  end

  def extract_groups
    ExtractsForClassification.from(@extracts)
  end

  def filter_objects
    @filter_objects ||= [
      ::Filters::FilterByRepeatedness,
      ::Filters::FilterByExtractorKeys,
      ::Filters::FilterByEmptiness,
      ::Filters::FilterByTrainingBehavior,
      ::Filters::FilterBySubrange
    ].map{ |klass| klass.new(filters) }
  end

  def apply_filters(extract_groups, filters)
    # this is a weird reduce: instead of applying a single aggregation method
    # to a series of data values, we apply a series of aggregation methods
    # to a single data object, with reduce threading the object through the
    # methods for us
    filters.reduce(extract_groups) do |current_extracts, filter|
      filter.apply(current_extracts).reject do |extract_group|
        extract_group.empty?
      end
    end.flat_map(&:extracts)
  end
end
