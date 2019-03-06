module Reducers
  module AggregationReducers
    class RectangleReducer < Reducers::AggregationReducer
      # refer to https://scikit-learn.org/stable/modules/generated/sklearn.cluster.DBSCAN.html
      ALGORITHM_NAMES = %w(auto ball_tree kd_tree brute).freeze

      config_field :eps, default: 5.0
      config_field :min_samples, default: 3
      config_field :metric, default: 'euclidean'
      config_field :algorithm, default: 'auto'
      config_field :leaf_size, default: 30
      config_field :p, default: nil

      validates :eps, numericality: true
      validates :min_samples, numericality: true
      validates :metric, inclusion: { in: AggregationReducer::METRIC_NAMES }
      validates :algorithm, inclusion: { in: RectangleReducer::ALGORITHM_NAMES }
      validates :leaf_size, numericality: true
      validates :p, numericality: true, allow_blank: true

      def reducer_name
        'rectangle_reducer'
      end
    end
  end
end
