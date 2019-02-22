module Reducers
  module AggregationReducers
    class RectangleReducer < Reducers::AggregationReducer
      # refer to https://scikit-learn.org/stable/modules/generated/sklearn.cluster.DBSCAN.html
      @@algorithm_names = ['auto', 'ball_tree', 'kd_tree', 'brute']

      def self.algorithm_names
        @@algorithm_names
      end

      config_field :eps, default: 5.0
      config_field :min_samples, default: 3
      config_field :metric, default: 'euclidean'
      config_field :algorithm, default: 'auto'
      config_field :leaf_size, default: 30
      config_field :p, default: nil

      validates :eps, numericality: true
      validates :min_samples, numericality: true
      validates :metric, inclusion: { in: AggregationReducer.metric_names }
      validates :algorithm, inclusion: { in: algorithm_names }
      validates :leaf_size, numericality: true
      validates :p, numericality: true, allow_blank: true

      def reducer_name
        'rectangle_reducer'
      end
    end
  end
end
