module Rules
  class Engine
    def initialize(rule_configs)
      @rules = rule_configs.map do |rule_config|
        Rule.new(Conditions::FromConfig.build(rule_config['if']),
                 Effects::FromConfig.build_many(rule_config['then']))
      end
    end

    def process(results)
      @rules.each { |rule| rule.process(results) }
    end
  end
end
