module Extractors
  module AggregationExtractors
    class ShapeExtractor < Extractors::AggregationExtractor
      config_field :shape
      validates :shape, inclusion: { in: AggregationExtractor.valid_shapes }

      def extractor_name
        'shape_extractor'
      end
    end
  end
end
