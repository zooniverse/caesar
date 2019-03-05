module Extractors
  class AggregationExtractor < Extractor
    include Extractors::HttpExtraction
    config_field :task_key, default: 'T0'

    def extract_data_for(classification)
      http_extract(classification)
    end

    def base_url
      'https://aggregation-caesar.zooniverse.org/extractors'
    end

    def collect_parameters
      self.class.merge_configuration_fields.map do |field, options|
        if (AggregationExtractor::BLACKLIST_FIELDS.include? field) || (self.send(field).blank?)
          nil
        else
          "#{field}=#{self.send field}"
        end
      end.compact.join("&")
    end

    def url
      "#{base_url}/#{extractor_name}?" + collect_parameters
    end

    BLACKLIST_FIELDS = [:url].freeze
    VALID_SHAPES = %w(circle column ellipse fullWidthLine fullHeightLine line point rectangle rotateRectangle triangle fan).freeze
  end
end
