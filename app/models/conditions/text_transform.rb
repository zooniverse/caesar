module Conditions
  class TextTransform
    attr_reader :transform, :operation

    def initialize(transform, operation)
      @transform = transform
      @operation = operation
    end

    def to_a
      [@transform, @operation.to_a]
    end

    def apply(bindings)
      value = operation.apply(bindings)
      raise TypeError, "Cannot run text transformation in rules for type #{value.class}" unless String === value

      case transform
      when :upcase
        value.upcase
      when :downcase
        value.downcase
      when :to_i
        value.to_i
      when :to_f
        value.to_f
      else
        value
      end
    end
  end
end
