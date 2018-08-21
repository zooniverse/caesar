class SubjectRuleEffect < ApplicationRecord
  belongs_to :subject_rule

  enum action: [:retire_subject, :add_subject_to_set, :add_subject_to_collection]

  validates :action, presence: true, inclusion: {in: SubjectRuleEffect.actions.keys}
  validate :valid_effect?

  def effect
    @effect ||= Effects[action].new(config)
  end

  def prepare(rule_id, workflow_id, subject_id)
    SubjectAction.create!(effect_type: action,
                   config: config,
                   rule_id: rule_id,
                   workflow_id: workflow_id,
                   subject_id: subject_id)
  end

  private

  def valid_effect?
    unless effect.valid?
      errors.add(:config, "Does not produce a valid effect")
    end
  end
end
