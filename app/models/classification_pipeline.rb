class ClassificationPipeline
  class ReductionConflict < StandardError; end

  attr_reader :reducible_class, :extractors, :reducers, :subject_rules, :user_rules, :rules_applied

  def initialize(reducible_class, extractors, reducers, subject_rules, user_rules, rules_applied = :all_matching_rules)
    @reducible_class = reducible_class
    @extractors = extractors
    @reducers = reducers
    @subject_rules = subject_rules
    @user_rules = user_rules
    @rules_applied = rules_applied
  end

  def process(classification)
    extract(classification)
    reduce(classification.workflow_id, classification.subject_id, classification.user_id)
    check_rules(classification.workflow_id, classification.subject_id, classification.user_id)
  end

  def extract(classification)
    RunsExtractors.new(reducible_class, extractors).extract(classification)
  end

  def reduce(reducible_id, subject_id, user_id, extract_ids=[])
    RunsReducers.new(reducible_class, reducers).reduce(reducible_id, subject_id, user_id, extract_ids)
  end

  def check_rules(reducible_id, subject_id, user_id)
    RunsRules.new(reducible_class, subject_rules, user_rules, rules_applied).check_rules(reducible_id, subject_id, user_id)
  end
end
