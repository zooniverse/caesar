class RunsSubjectRules
  attr_reader :reducible, :rules, :user_rules, :rules_applied

  def initialize(reducible, rules, rules_applied = :all_matching_rules)
    @reducible = reducible
    @rules = rules
    @rules_applied = rules_applied
  end

  def check_rules(subject_id)
    return unless rules.present?

    subject = Subject.find(subject_id)
    rule_bindings = RuleBindings.new(subject_reductions(subject_id), subject)

    case rules_applied.to_s
    when 'all_matching_rules'
      rules.each do |rule|
        rule.process(subject_id, rule_bindings)
      end
    when 'first_matching_rule'
      rules.find do |rule|
        rule.process(subject_id, rule_bindings)
      end
    end
  end

  def subject_reductions(subject_id)
    SubjectReduction.where(reducible_id: reducible.id, reducible_type: reducible.class.to_s, subject_id: subject_id)
  end
end
