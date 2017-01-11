module Rules
  class Comparison
    def initialize(type, operations)
      @type = type
      @operations = operations
    end

    def apply(bindings)
      values = @operations.lazy.map { |operation| operation.apply(bindings) }

      case @type
      when :lt
        compare(values) { |a, b| a < b }
      when :lte
        compare(values) { |a, b| a <= b }
      when :gt
        compare(values) { |a, b| a > b }
      when :gte
        compare(values) { |a, b| a >= b }
      when :eq
        compare(values) { |a, b| a == b }
      else
        raise "Unknown type of comparison: #{@type}"
      end
    end

    def compare(values)
      !!values.reduce do |memo, value|
        if yield memo, value
          next value
        else
          break false
        end
      end
    end
  end
end
