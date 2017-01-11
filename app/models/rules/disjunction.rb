module Rules
  class Disjunction
    def initialize(operations)
      @operations = operations
    end

    def apply(bindings)
      @operations.reduce(false) { |memo, operation| memo || operation.apply(bindings) }
    end
  end
end
