module Conditions
  class Lookup
    attr_reader :key, :absent_val

    def initialize(key, absent_val)
      @key = key
      @absent_val = absent_val
    end

    def apply(bindings)
      bindings.fetch(@key, @absent_val)
    end
  end
end
