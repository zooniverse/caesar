class ExtractFilter
  include ActiveModel::Validations
  validates_with ActiveRecord::Validations::AssociatedValidator,
    _merge_attributes([:filter_objects])

  attr_reader :filter_config

  def initialize(config)
    @filter_config = config.with_indifferent_access
  end

  def apply(extracts)
    classification_groups = ExtractsForClassification.from(extracts)
    apply_filters(classification_groups, filter_objects)
  end

  private

  def filter_objects
    # configure an array of filter objects to be applied in order
    @filter_objects ||= [
      ::Filters::FilterByRepeatedness,
      ::Filters::FilterByExtractorKeys,
      ::Filters::FilterByEmptiness,
      ::Filters::FilterByTrainingBehavior,
      ::Filters::FilterBySubrange
    ].map{ |klass| klass.new(filter_config) }
  end

  def apply_filters(classification_groups, configured_filters)
    # this is a weird reduce: instead of applying a single aggregation method
    # to a series of data values, we apply a series of aggregation methods
    # to a single data object, with reduce threading the object through the
    # methods for us
    configured_filters.reduce(classification_groups) do |classification_group, filter|
      # apply each filter in order; throw away each classification group when it becomes empty
      filter.apply(classification_group).reject{ |filtered_group| filtered_group.empty? }
    end.flat_map(&:extracts)
  end
end
