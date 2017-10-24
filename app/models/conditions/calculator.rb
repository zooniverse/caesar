module Conditions
  class Calculator
    attr_reader :type, :operations

    def initialize(type, operations)
      @type = type
      @operations = operations
    end

    def apply(bindings)
      values = operations.map { |op| op.apply(bindings) }
      case type
      when '+'
        values.reduce(&:+)
      when '-'
        values.reduce(&:-)
      when '*'
        values.reduce(&:*)
      when '/'
        values.map(&:to_f).reduce(&:/)
      when '%'
        values.reduce(&:%)
      end
    end
  end
end
