module Conditions
  class Lookup
    def initialize(key, absent_val=nil)
      @key = key
      @absent_val = absent_val
    end

    def apply(bindings)
      bindings.fetch(@key, @absent_val)
    end
  end
end
