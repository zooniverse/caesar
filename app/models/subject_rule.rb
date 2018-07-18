class SubjectRule < ApplicationRecord
  include RankedModel
  ranks :row_order, with_same: :workflow_id

  belongs_to :workflow
  has_many :subject_rule_effects

  validate :valid_condition?

  enum topic: {
    evaluate_by_subject: 0,
    evaluate_by_user: 1
  }

  def condition
    Conditions::FromConfig.build(self[:condition]) unless self[:condition].blank?
  end

  def condition_string
    condition.to_a.to_s
  end

  def process(subject_id, bindings)
    if condition.apply(bindings)
      subject_rule_effects.each do |effect|
        pending_action = effect.prepare(id, workflow_id, subject_id)
        PerformSubjectActionWorker.perform_async(pending_action.id)
      end
    else
      false
    end
  end

  def valid_condition?
    condition
  rescue Conditions::FromConfig::InvalidConfig => ex
    errors.add(:condition, ex.message)
  end
end
