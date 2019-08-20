module Conditions
  class Lookup
    attr_reader :key, :absent_val

    def initialize(key, absent_val)
      @key = key
      @absent_val = absent_val
    end

    def absent_val_display
      @absent_val.instance_of?(String) ? "'" + @absent_val.to_s + "'" : @absent_val
    end

    def to_a
      ["lookup", @key, @absent_val]
    end

    def apply(bindings)
      bindings.fetch(@key, @absent_val)
    end

  end
end
