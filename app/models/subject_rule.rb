class SubjectRule < ApplicationRecord
  include RankedModel
  ranks :row_order, with_same: :workflow_id

  belongs_to :workflow, counter_cache: true
  has_many :subject_rule_effects, dependent: :destroy

  validate :valid_condition?

  enum :topic, {
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
    light = Stoplight("subject-rule-#{id}") do
      if condition.apply(bindings)
        subject_rule_effects.each do |effect|
          pending_action = effect.prepare(id, workflow_id, subject_id)
          PerformSubjectActionWorker.perform_async(pending_action.id)
        end
      else
        false
      end
    end

    light.run
  end

  def valid_condition?
    condition
  rescue Conditions::FromConfig::InvalidConfig => ex
    errors.add(:condition, ex.message)
  end

  def stoplight_color
    @color ||= Stoplight("subject-rule-#{id}").color
  end
end
