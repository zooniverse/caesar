class ClassificationPipeline
  attr_reader :extractors, :reducers, :subject_rules, :user_rules

  def initialize(extractors, reducers, subject_rules, user_rules)
    @extractors = extractors
    @reducers = reducers
    @subject_rules = subject_rules
    @user_rules = user_rules
  end

  def process(classification)
    extract(classification)
    reduce(classification.workflow_id, classification.subject_id, classification.user_id)
    check_rules(classification.workflow_id, classification.subject_id, classification.user_id)
  end

  def extract(classification)
    workflow = classification.workflow
    PerformExtraction.new(workflow).extract(classification)
  end

  def reduce(workflow_id, subject_id, user_id)
    workflow = Workflow.find(workflow_id)
    PerformReduction.new(workflow).reduce(subject_id, user_id)
  end

  def check_rules(workflow_id, subject_id, user_id)
    check_subject_rules(workflow_id, subject_id)
    check_user_rules(workflow_id, user_id)
  end

  private

  def check_subject_rules(workflow_id, subject_id)
    return unless subject_rules.present?

    subject = Subject.find(subject_id)

    rule_bindings = RuleBindings.new(subject_reductions(workflow_id, subject_id), subject)
    subject_rules.each do |rule|
      rule.process(subject_id, rule_bindings)
    end
  end

  def check_user_rules(workflow_id, user_id)
    return unless (user_rules.present? and not user_id.blank?)

    rule_bindings = RuleBindings.new(user_reductions(workflow_id, user_id), nil)
    user_rules.each do |rule|
      rule.process(user_id, rule_bindings)
    end
  end

  def user_reductions(workflow_id, user_id)
    UserReduction.where(workflow_id: workflow_id, user_id: user_id)
  end

  def subject_reductions(workflow_id, subject_id)
    SubjectReduction.where(workflow_id: workflow_id, subject_id: subject_id)
  end
end
