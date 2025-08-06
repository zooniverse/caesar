class Reducer < ApplicationRecord
  include Configurable
  include BelongsToReducibleCached
  class UnknownTypeError < StandardError; end

  enum :topic, reduce_by_subject: 0, reduce_by_user: 1

  enum :reduction_mode, default_reduction: 0, running_reduction: 1

  def self.of_type(type)
    case type.to_s
    when 'consensus'
      Reducers::ConsensusReducer
    when 'count'
      Reducers::CountReducer
    when 'placeholder'
      Reducers::PlaceholderReducer
    when 'external'
      Reducers::ExternalReducer
    when 'first_extract'
      Reducers::FirstExtractReducer
    when 'stats'
      Reducers::StatsReducer
    when 'summary_stats'
      Reducers::SummaryStatisticsReducer
    when 'unique_count'
      Reducers::UniqueCountReducer
    when 'rectangle'
      Reducers::AggregationReducers::RectangleReducer
    when 'sqs'
      Reducers::SqsReducer
    else
      raise UnknownTypeError, "Unknown type #{type}"
    end
  end

  validates :key, presence: true, uniqueness: {scope: [:workflow_id]}
  validates :topic, presence: true
  validates_associated :extract_filter

  before_validation :nilify_empty_fields

  config_field :user_reducer_keys, default: nil
  config_field :subject_reducer_keys, default: nil

  NoData = Class.new

  def process(extracts, reduction_fetcher, relevant_reductions=[])
    light = Stoplight("reducer-#{id}") do
      return [] if extracts.empty?

      grouped_extracts = ExtractGrouping.new(extracts, grouping).to_h

      grouped_extracts.map do |group_key, grouped|
        reduction = get_reduction(reduction_fetcher, group_key)
        extracts = filter_extracts(grouped, reduction)
        next if extracts.empty?

        # Set relevant reduction on each extract if required by external reducer
        # relevant_reductions are any previously reduced user or subject reductions
        # that are required by this reducer to properly calculate
        augmented_extracts = add_relevant_reductions(extracts, relevant_reductions)

        reduce_into(augmented_extracts, reduction).tap do |r|
          # note that because we use deferred associations, this won't actually hit the database
          # until the reduction is saved, meaning it happens inside the transaction
          associate_extracts(r, extracts) if running_reduction?
        end
      end.select{ |reduction| reduction&.data&.present? }
    end

    light.run
  end

  def get_reduction(reduction_fetcher, group_key)
    if running_reduction?
      reduction_fetcher.retrieve_in_place(reducer_key: key, subgroup: group_key).tap do |r|
        r.data ||= {}
        r.store ||= {}
      end
    else
      reduction_fetcher.retrieve(reducer_key: key, subgroup: group_key).tap do |r|
        # send empty data and store unless we're in running reduction mode
        r.data = {}
        r.store = {}
      end
    end
  end

  def filter_extracts(extracts, reduction)
    extracts = extracts.reject{ |extract| reduction.extract_ids.include? extract.id }
    extract_filter.apply(extracts)
  end

  def associate_extracts(reduction, extracts)
    extracts.each do |extract|
      reduction.extracts << extract
    end
  end

  def reduce_into(extracts, reduction)
    raise NotImplementedError
  end

  def extract_filter
    ExtractFilter.new(filters)
  end

  def stoplight_color
    @color ||= Stoplight("reducer-#{id}").color
  end

  def config
    super || {}
  end

  def filters
    super || {}
  end

  def grouping
    super || {}
  end

  def nilify_empty_fields
  end

  def add_relevant_reductions(extracts, relevant_reductions)
    extracts.map do |ex|
      ex.relevant_reduction = case topic
                              when 0, "reduce_by_subject"
                                relevant_reductions.find { |rr| rr.user_id == ex.user_id }
                              when 1, "reduce_by_user"
                                relevant_reductions.find { |rr| rr.subject_id == ex.subject_id }
                              end
    end
    extracts
  end
end
