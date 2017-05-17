module Rules
  class Rule
    attr_reader :condition, :effects

    def initialize(condition, effects)
      @condition = condition
      @effects = effects
    end

    def process(workflow_id, subject_id, bindings)
      if condition.apply(bindings)
        effects.each do |effect|
          pending_action = effect.prepare(workflow_id, subject_id)
          PerformActionWorker.perform_async(pending_action.id)
        end
      end
    end
  end
end
