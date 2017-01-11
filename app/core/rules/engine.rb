require_relative 'rule'
require_relative 'condition_from_config'
require_relative 'effect_from_config'

module Rules
  class Engine
    def initialize(rule_configs)
      @rules = rule_configs.map do |rule_config|
        Rule.new(ConditionFromConfig.build(config[:if]),
                 EffectFromConfig.build_many(config[:then]))
      end
    end

    def process(results)
      @rules.each { |rule| rule.process(results) }
    end
  end
end
