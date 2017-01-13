module Rules
  class Rule
    attr_reader :condition, :effects

    def initialize(condition, effects)
      @condition = condition
      @effects = effects
    end

    def process(workflow_id, subject_id, results)
      if condition.apply(results)
        effects.each { |effect| effect.perform(workflow_id, subject_id) }
      end
    end
  end
end
