module Conditions
  class Conjunction
    attr_reader :operations

    def initialize(operations)
      @operations = operations
    end

    def to_a
      ["and"] + @operations.map(&:to_a)
    end

    def apply(bindings)
      @operations.reduce(true) { |memo, operation| memo && operation.apply(bindings) }
    end
  end
end
