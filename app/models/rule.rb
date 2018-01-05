class Rule < ApplicationRecord
  enum topic: {
    for_subjects: 0,
    for_users: 1
  }

  belongs_to :workflow
  has_many :rule_effects

  validate :valid_condition?

  def condition
    Conditions::FromConfig.build(self[:condition])
  end

  def process(subject_id, user_id, bindings)
    if condition.apply(bindings)
      rule_effects.each do |effect|
        pending_action = effect.prepare(id, workflow_id, subject_id, user_id)
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
