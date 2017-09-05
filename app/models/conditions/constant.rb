module Conditions
  class Constant
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def apply(bindings)
      @value
    end
  end
end
