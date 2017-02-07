module Reducers
  class Reducer
    attr_reader :id, :config

    def initialize(id, config = {})
      @id = id
      @config = config
    end

    def group_extracts(extracts)
      extracts
        .group_by(&:classification_id)
        .map{ |k,v| { :classification_id => k, :data => v } }
        .sort_by{ |hash| hash[:data][0].classification_at }
    end

    def apply_subranges(collection)
      if subranges
        subranges.flat_map{ |r| collection[Range.new(r[:from],r[:to])] }
      else
        collection
      end
    end

    def filter_extracts(extracts)
      apply_subranges(group_extracts(extracts))
        .flat_map{ |g| g[:data] }
    end

    def subranges
      config["subranges"]
    end

  end
end
