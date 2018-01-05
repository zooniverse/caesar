class ClonesWorkflowConfiguration < ApplicationOperation
  attr_reader :from, :to

  def initialize(from, to)
    @from = from
    @to = to
  end

  def copy
    from.extractors.each do |extractor|
      extractor.class.create!(workflow: to,
                              key: extractor.key,
                              config: extractor.config,
                              minimum_workflow_version: extractor.minimum_workflow_version)
    end

    from.reducers.each do |reducer|
      reducer.class.create!(workflow: to,
                            key: reducer.key,
                            config: reducer.config,
                            grouping: reducer.grouping,
                            filters: reducer.filters)
    end

    from.subject_rules.each do |rule|
      rule_copy = SubjectRule.create!(workflow: to,
                               condition: rule[:condition])

      rule.subject_rule_effects.each do |rule_effect|
        SubjectRuleEffect.create!(subject_rule: rule_copy,
                           action: rule_effect.action,
                           config: rule_effect.config)
      end
    end
  end
end
