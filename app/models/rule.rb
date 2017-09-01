class Rule < ApplicationRecord
  belongs_to :workflow
  has_many :rule_effects

  def condition
    Conditions::FromConfig.build(self[:condition])
  end

  def process(workflow_id, subject_id, bindings)
    if condition.apply(bindings)
      rule_effects.each do |effect|
        pending_action = effect.prepare(workflow_id, subject_id)
        PerformActionWorker.perform_async(pending_action.id)
      end
    end
  end
end
