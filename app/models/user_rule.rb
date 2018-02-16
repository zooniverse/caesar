class UserRule < ApplicationRecord
  include RankedModel
  ranks :row_order

  belongs_to :workflow
  has_many :user_rule_effects

  validate :valid_condition?

  def condition
    Conditions::FromConfig.build(self[:condition])
  end

  def process(user_id, bindings)
    if condition.apply(bindings)
      user_rule_effects.each do |effect|
        pending_action = effect.prepare(id, workflow_id, user_id)
        PerformUserActionWorker.perform_async(pending_action.id)
      end
    end
  end

  def valid_condition?
    condition
  rescue Conditions::FromConfig::InvalidConfig => ex
    errors.add(:condition, ex.message)
  end
end
