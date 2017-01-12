module Conditions
  class Conjunction
    def initialize(operations)
      @operations = operations
    end

    def apply(bindings)
      @operations.reduce(true) { |memo, operation| memo && operation.apply(bindings) }
    end
  end
end
