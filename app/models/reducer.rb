class Reducer < ApplicationRecord
  include Configurable
  include BelongsToReducibleCached

  attr_reader :subject_id, :user_id

  enum topic: {
    reduce_by_subject: 0,
    reduce_by_user: 1
  }

  enum reduction_mode: {
    default_reduction: 0,
    running_reduction: 1
  }

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
      raise "Unknown type #{type}"
    end
  end

  validates :key, presence: true, uniqueness: {scope: [:workflow_id]}
  validates :topic, presence: true
  validates_associated :extract_filter

  config_field :user_reducer_keys, default: nil
  config_field :subject_reducer_keys, default: nil

  NoData = Class.new

  def process(extracts, reductions, subject_id=nil, user_id=nil)
    @subject_id = subject_id
    @user_id = user_id

    light = Stoplight("reducer-#{id}") do
      return [] if extracts.empty?

      grouped_extracts = ExtractGrouping.new(extracts, grouping).to_h

      grouped_extracts.map do |group_key, extract_group|
        # find or create the reduction we want to reduce into
        reduction = get_group_reduction(reductions, group_key)

        # now that we have the reduction, filter the extracts based
        # on the filters and on reduction.extracts if it exists
        extracts = filter_extracts(extract_group, reduction)

        # reduce the extracts into the correct reduction
        reduce_into(extracts, reduction).tap do |r|
          # if we are in running reduction, we never want to reduce the same extract twice, so this
          # means that we must keep an association of which extracts are already part of a reduction
          if running_reduction?
              associate_extracts(r, extracts)
          end
        end
      end.select{ |reduction| reduction&.data&.present? }
    end

    light.run
  end

  # for each extract, try to find a relevant reduction if relevant
  # reductions are configured
  #
  # relevant_reductions are any previously reduced user or subject reductions
  # that are required by this reducer to properly calculate
  def augment_extracts(extracts)
    relevant_reductions = get_relevant_reductions(extracts)
    return extracts if relevant_reductions.empty?

    extracts.each do |ex|
      ex.relevant_reduction = if reduce_by_subject?
          # find will only return the first match
          relevant_reductions.find { |rr| rr.user_id == ex.user_id }
        elsif reduce_by_user?
          # find will only return the first match
          relevant_reductions.find { |rr| rr.subject_id == ex.subject_id }
        else
          raise NotImplementedError.new 'This reduction topic is not supported'
        end
    end
  end

  # load all reductions that might be relevant to any of the extracts that are
  # being reduced
  def get_relevant_reductions(extracts)
    return [] if user_reducer_keys.blank? && subject_reducer_keys.blank?

    if reduce_by_subject?
      UserReduction.where(user_id: extracts.map(&:user_id), reducible: reducible, reducer_key: user_reducer_keys)
    elsif reduce_by_user?
      SubjectReduction.where(subject_id: extracts.map(&:subject_id), reducible: reducible, reducer_key: subject_reducer_keys)
    else
      raise NotImplementedError.new 'This reduction mode is not supported'
    end
  end

  # apply extract filters and deduplicate extracts (do not allow a running reduction
  # to contain the same extract twice)
  def filter_extracts(extracts, reduction)
    return extracts if extracts.blank?

    extracts = extract_filter.apply(extracts)
    if running_reduction?
      extracts = extracts.reject { |extract| reduction.extract_ids.include? extract.id }
    end

    extracts
  end

  # given an array of reductions to be updated, find or create one with the
  # appropriate keys
  def get_group_reduction(reductions, group_key)
    requested_reduction = reductions.find{ |reduction| reduction.subgroup == group_key }
    if requested_reduction.present?
      requested_reduction
    elsif reduce_by_subject?
      SubjectReduction.new \
        reducible: reducible,
        reducer_key: key,
        subgroup: group_key,
        subject_id: subject_id,
        data: {},
        store: {}
    elsif reduce_by_user?
      UserReduction.new \
        reducible: reducible,
        reducer_key: key,
        subgroup: group_key,
        user_id: user_id,
        data: {},
        store: {}
    else
      raise NotImplementedError.new 'This topic is not supported'
    end
  end

  def associate_extracts(reduction, extracts)
    # note that because we use deferred associations, this won't actually hit the database
    # until the reduction is saved, meaning it happens inside the transaction that originates
    # in RunsReducers#persist_reductions
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
end
