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
      blacklist_fields = [:url]

      self.class.merge_configuration_fields.map do |field, options|
        if (blacklist_fields.include? field) || (self.send(field).blank?)
          nil
        else
          "#{field}=#{self.send field}"
        end
      end.compact.join("&")
    end

    def url
      "#{base_url}/#{extractor_name}?" + collect_parameters
    end

    @@valid_shapes = [
      'circle',
      'column',
      'ellipse',
      'fullWidthLine',
      'fullHeightLine',
      'line',
      'point',
      'rectangle',
      'rotateRectangle',
      'triangle',
      'fan'
    ]

    def self.valid_shapes
      @@valid_shapes
    end
  end
end
