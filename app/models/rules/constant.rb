module Rules
  class Constant
    def initialize(value)
      @value = value
    end

    def apply(bindings)
      @value
    end
  end
end
