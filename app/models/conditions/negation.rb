module Conditions
  class Negation
    attr_reader :operation

    def initialize(operation)
      @operation = operation
    end

    def to_a
      ["not", @operation.to_a]
    end

    def apply(bindings)
      !@operation.apply(bindings)
    end
  end
end
