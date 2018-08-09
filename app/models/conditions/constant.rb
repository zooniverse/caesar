module Conditions
  class Constant
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def to_a
      ["const", @value]
    end

    def apply(bindings)
      @value
    end
  end
end
