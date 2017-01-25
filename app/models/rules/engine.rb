module Rules
  class Engine
    def initialize(rule_configs)
      @rules = Array.wrap(rule_configs).map do |rule_config|
        Rule.new(Conditions::FromConfig.build(rule_config['if']),
                 Effects::FromConfig.build_many(rule_config['then']))
      end
    end

    def process(workflow_id, subject_id, results)
      @rules.each { |rule| rule.process(workflow_id, subject_id, results) }
    end

    def present?
      @rules.size > 0
    end

    def size
      @rules.size
    end
  end
end
