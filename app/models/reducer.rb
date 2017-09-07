class Reducer < ApplicationRecord
  belongs_to :workflow

  NoData = Class.new

  def process(extracts)
    filtered_extracts = ExtractFilter.new(extracts, filters).to_a
    grouped_extracts = ExtractGrouping.new(filtered_extracts, grouping).to_h
    grouped_extracts.map do |key, grouped|
      [key, reduction_data_for(grouped)]
    end.to_h
  end

  def config
    super || {}
  end

  def filters
    super || {}
  end

  #   end
  # end
end
