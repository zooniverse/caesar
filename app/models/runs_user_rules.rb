class RunsUserRules
  attr_reader :reducible, :subject_rules, :rules, :rules_applied

  def initialize(reducible, rules, rules_applied = :all_matching_rules)
    @reducible = reducible
    @rules = rules
    @rules_applied = rules_applied
  end

  def check_rules(user_id)
    return unless (rules.present? and not user_id.blank?)

    rule_bindings = RuleBindings.new(user_reductions(user_id), nil)
  
    case rules_applied.to_s
    when 'all_matching_rules'
      rules.each do |rule|
        rule.process(user_id, rule_bindings)
      end
    when 'first_matching_rule'
      rules.find do |rule|
        rule.process(user_id, rule_bindings)
      end
    end
  end

  def user_reductions(user_id)
    UserReduction.where(reducible_id: reducible.id, reducible_type: reducible.class.to_s, user_id: user_id)
  end
end
  