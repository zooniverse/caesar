class Reducer < ApplicationRecord
  include Configurable

  enum topic: {
    reduce_by_subject: 0,
    reduce_by_user: 1
  }

  def self.of_type(type)
    case type.to_s
    when "consensus"
      Reducers::ConsensusReducer
    when "count"
      Reducers::CountReducer
    when 'placeholder'
      Reducers::PlaceholderReducer
    when "external"
      Reducers::ExternalReducer
    when "first_extract"
      Reducers::FirstExtractReducer
    when "stats"
      Reducers::StatsReducer
    when "summary_stats"
      Reducers::SummaryStatisticsReducer
    when "unique_count"
      Reducers::UniqueCountReducer
    else
      raise "Unknown type #{type}"
    end
  end

  belongs_to :workflow

  validates :workflow, presence: true
  validates :key, presence: true, uniqueness: {scope: [:workflow_id]}
  validates :topic, presence: true
  validates_associated :extract_filter

  before_validation :nilify_empty_fields

  NoData = Class.new

  def process(extracts)
    light = Stoplight("reducer-#{id}") do
      grouped_extracts = ExtractGrouping.new(extracts, grouping).to_h

      grouped_extracts.map do |key, grouped|
        [key, reduction_data_for(extract_filter.filter(grouped))]
      end.to_h
    end

    light.run
  end

  def reduction_data_for(extracts)
    raise NotImplementedError
  end

  def extract_filter
    ExtractFilter.new(filters)
  end

  def config
    super || {}
  end

  def filters
    super || {}
  end

  def nilify_empty_fields
    self.grouping = nil if grouping.blank?
  end
end
