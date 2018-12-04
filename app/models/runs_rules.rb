class RunsRules
  attr_reader :reducible_class, :subject_rules, :user_rules, :rules_applied

  def initialize(reducible_class, subject_rules, user_rules, rules_applied = :all_matching_rules)
    @reducible_class = reducible_class
    @subject_rules = subject_rules
    @user_rules = user_rules
    @rules_applied = rules_applied
  end

  def check_rules(reducible_id, subject_id, user_id)
    check_subject_rules(reducible_id, subject_id)
    check_user_rules(reducible_id, user_id)
  end

  private

  def check_subject_rules(reducible_id, subject_id)
    return unless subject_rules.present?

    subject = Subject.find(subject_id)
    rule_bindings = RuleBindings.new(subject_reductions(reducible_id, subject_id), subject)

    case rules_applied.to_s
    when 'all_matching_rules'
      subject_rules.each do |rule|
        rule.process(subject_id, rule_bindings)
      end
    when 'first_matching_rule'
      subject_rules.find do |rule|
        rule.process(subject_id, rule_bindings)
      end
    end
  end

  def check_user_rules(reducible_id, user_id)
    return unless (user_rules.present? and not user_id.blank?)

    rule_bindings = RuleBindings.new(user_reductions(reducible_id, user_id), nil)
    case rules_applied.to_s
    when 'all_matching_rules'
      user_rules.each do |rule|
        rule.process(user_id, rule_bindings)
      end
    when 'first_matching_rule'
      user_rules.find do |rule|
        rule.process(user_id, rule_bindings)
      end
    end
  end

  def user_reductions(reducible_id, user_id)
    UserReduction.where(reducible_id: reducible_id, reducible_type: reducible_class.to_s, user_id: user_id)
  end

  def subject_reductions(reducible_id, subject_id)
    SubjectReduction.where(reducible_id: reducible_id, reducible_type: reducible_class.to_s, subject_id: subject_id)
  end
end
