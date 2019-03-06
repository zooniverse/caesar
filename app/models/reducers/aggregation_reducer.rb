
module Reducers
  class AggregationReducer < Reducer
    include Reducers::HttpReduction

    def reduce_into(extracts, reduction, relevant_reductions=[])
      if default_reduction?
        http_reduce(reduction, extracts)
      elsif running_reduction?
        http_reduce(reduction, {
          extracts: extracts,
          store: reduction.store,
          relevant_reductions: relevant_reductions
        })
      else
        raise ExternalReducerFailed.new 'Impossible configuration, select default_reduction or running_reduction'
      end
    rescue StandardError => e
      raise ExternalReducerFailed.new e.to_s
    end

    def base_url
      'https://aggregation-caesar.zooniverse.org/reducers'
    end

    def collect_parameters
      self.class.merge_configuration_fields.map do |field, options|
        if (AggregationReducer::BLACKLIST_FIELDS.include? field) || (self.send(field).blank?)
          nil
        else
          "#{field}=#{self.send field}"
        end
      end.compact.join("&")
    end

    def url
      "#{base_url}/#{reducer_name}?" + collect_parameters
    end

    BLACKLIST_FIELDS = [:url, :user_reducer_keys, :subject_reducer_keys].freeze
    # refer to https://scikit-learn.org/stable/modules/generated/sklearn.metrics.pairwise_distances.html#sklearn.metrics.pairwise_distances
    METRIC_NAMES = %w(
      cityblock cosine euclidean l1 l2 manhattan
      braycurtis, canberra, chebyshev, correlation, dice, hamming, jaccard, kulsinski, mahalanobis, minkowski, rogerstanimoto, russellrao, seuclidean, sokalmichener, sokalsneath, sqeuclidean, yule
    ).freeze
  end
end
