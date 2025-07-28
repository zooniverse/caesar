class ExtractFilter
  include ActiveModel::Validations
  validate :validate_individual_filter_objects

  attr_reader :filter_config

  def initialize(config)
    @filter_config = config.with_indifferent_access
  end

  def apply(extracts)
    extracts_by_classification = ExtractsForClassification.from(extracts)
    apply_filters(extracts_by_classification, filter_objects)
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


  def validate_individual_filter_objects
    unless filter_objects.respond_to?(:each)
      errors.add(:filter_objects, "must be a collection")
    end

    filter_objects.each_with_index do |filter_obj, index|
      if filter_obj.respond_to?(:valid?) && !filter_obj.valid?
        filter_obj.errors.full_messages.each do |message|
          errors.add(:filter_objects, "at index #{index} is invalid: #{message}")
        end
      end
    end
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
