class ConvertWorkflowRules < ActiveRecord::Migration[5.1]
  def change
    RuleEffect.delete_all
    Rule.delete_all

    Workflow.find_each do |workflow|
      workflow.rules_config.each do |rule_config|
        rule = workflow.rules.build(condition: rule_config["if"])

        rule_config["then"].each do |effect|
          rule.rule_effects.build(action: effect["action"], config: effect.except("action"))
        end

        rule.save!
      end
    end
  end
end
