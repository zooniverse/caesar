module Conditions
  class TextTransform
    attr_reader :transform, :operation

    def initialize(transform, operation)
      @transform = transform
      @operation = operation
    end

    def to_a
      [@transform.to_s, @operation.to_a]
    end

    def apply(bindings)
      value = operation.apply(bindings)

      case transform
      when :upcase
        raise TypeError, "Cannot upcase for non-string type #{value.class}" unless String === value
        value.upcase
      when :downcase
        raise TypeError, "Cannot downcase for non-string type #{value.class}" unless String === value
        value.downcase
      when :to_i
        raise TypeError, "Cannot convert type #{value.class} to integer" unless (String === value) || (Integer === value)
        value.to_i
      when :to_f
        raise TypeError, "Cannot run text transformation in rules for type #{value.class}" unless (String === value) || (Numeric === value)
        value.to_f
      else
        value
      end
    end
  end
end
