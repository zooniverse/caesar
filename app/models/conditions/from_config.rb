module Conditions
  module FromConfig
    class InvalidConfig < StandardError; end

    def self.build(config)
      case config[0].to_s
      when 'not'
        Negation.new(build(config[1]))
      when 'and'
        Conjunction.new(build_many(config[1..-1]))
      when 'or'
        Disjunction.new(build_many(config[1..-1]))
      when 'any'
        Any.new(config[1], build(config[2]))
      when 'all'
        All.new(config[1], build(config[2]))
      when 'eq', 'gt', 'gte', 'lt', 'lte'
        Comparison.new(config[0], build_many(config[1..-1]))
      when 'const'
        Constant.new(config[1])
      when 'lookup'
        raise InvalidConfig, "Not enough arguments given to lookup" unless config[1..-1].size == 2
        Lookup.new(config[1], config[2])
      when 'upcase'
        TextTransform.new(:upcase, build(config[1]))
      when 'downcase'
        TextTransform.new(:downcase, build(config[1]))
      else
        raise InvalidConfig, "Unknown rule type: #{config[0]} (in #{config.inspect})"
      end
    end

    def self.build_many(configs)
      configs.map { |config| build(config) }
    end
  end
end
