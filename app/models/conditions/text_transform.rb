module Conditions
  class TextTransform
    attr_reader :transform, :operation

    def initialize(transform, operation)
      @transform = transform
      @operation = operation
    end

    def apply(bindings)
      value = operation.apply(bindings)
      raise TypeError, "Cannot run text transformation in rules for type #{value.class}" unless String === value

      case transform
      when :upcase
        value.upcase
      when :downcase
        value.downcase
      else
        value
      end
    end
  end
end
