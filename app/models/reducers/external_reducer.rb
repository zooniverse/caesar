require 'uri'

module Reducers
  class ExternalReducer < Reducer
    include Reducers::HttpReduction

    class ExternalReducerFailed < StandardError; end

    config_field :url, default: nil
    config_field :version, default: 1

    def reduce_into(extracts, reduction)
      return nil if extracts.empty?
      if default_reduction?
        http_reduce(reduction, extracts)
      elsif running_reduction?
        http_reduce(reduction, {
          extracts: extracts,
          store: reduction.store,
        })
      else
        raise ExternalReducerFailed.new "Impossible configuration, select default_reduction or running_reduction"
      end
    rescue StandardError => e
      raise ExternalReducerFailed.new e.to_s
    end
  end
end
