module Reducers
  class ReductionResults
    def self.build
      results = new
      yield results
      results.to_h
    end

    def initialize
      @value = {}
    end

    def increment(key)
      @value[key] ||= 0
      @value[key] += 1
    end

    def to_h
      @value
    end
  end
end
