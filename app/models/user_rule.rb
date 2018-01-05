class UserRule < ApplicationRecord
  belongs_to :workflow
  has_many :user_rule_effects

  def condition
    Conditions::FromConfig.build(self[:condition])
  end

  def process(subject_id, bindings)
    if condition.apply(bindings)
      user_rule_effects.each do |effect|
        pending_action = effect.prepare(id, workflow_id, subject_id)
        PerformActionWorker.perform_async(pending_action.id)
      end
    end
  end

  def valid_condition?
    condition
  rescue Conditions::FromConfig::InvalidConfig => ex
    errors.add(:condition, ex.message)
  end
end
