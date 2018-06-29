module Conditions
  class Disjunction
    attr_reader :operations

    def initialize(operations)
      @operations = operations
    end

    def to_a
      ["or"] + @operations.map(&:to_a)
    end

    def apply(bindings)
      @operations.reduce(false) { |memo, operation| memo || operation.apply(bindings) }
    end
  end
end
