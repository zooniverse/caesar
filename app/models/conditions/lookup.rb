module Conditions
  class Lookup
    def initialize(key)
      @key = key
    end

    def apply(bindings)
      bindings.fetch(@key)
    end
  end
end
