class ClassificationPipeline
  class ReductionConflict < StandardError; end

  attr_reader :extractors, :reducers, :subject_rules, :user_rules, :rules_applied

  def initialize(extractors, reducers, subject_rules, user_rules, rules_applied = :all_matching_rules)
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
    return [] unless extractors&.present?

    tries ||= 2

    workflow = Workflow.find(classification.workflow_id)

    novel_subject = Extract.where(subject_id: classification.subject_id, workflow_id: classification.workflow_id).empty?
    novel_user = classification.user_id.present? && Extract.where(user_id: classification.user_id, workflow_id: classification.workflow_id).empty?

    extracts = extractors.map do |extractor|
      data = extractor.process(classification)

      extract = Extract.where(workflow_id: classification.workflow_id, subject_id: classification.subject_id, classification_id: classification.id, extractor_key: extractor.key).first_or_initialize
      extract.user_id = classification.user_id
      extract.classification_at = classification.created_at
      extract.data = data
      extract.save!

      extract
    end

    if workflow.concerns_subjects? and novel_subject
      FetchClassificationsWorker.perform_async(classification.workflow_id, classification.subject_id, FetchClassificationsWorker.fetch_for_subject)
    end

    if workflow.concerns_users? and novel_user
      FetchClassificationsWorker.perform_async(classification.workflow_id, classification.user_id, FetchClassificationsWorker.fetch_for_user)
    end

    extracts
  rescue ActiveRecord::RecordNotUnique, PG::UniqueViolation
    sleep 2
    retry unless (tries-=1).zero?
    raise
  end

  def reduce(workflow_id, subject_id, user_id, extract_ids=[])
    return [] unless reducers&.present?
    tries ||= 2

    extracts = ExtractFetcher.new(workflow_id, subject_id, user_id, extract_ids)

    # prefetch all reductions to avoid race conditions with optimistic locking
    subject_reductions = SubjectReduction.where(workflow_id: workflow_id, subject_id: subject_id)
    user_reductions = UserReduction.where(workflow_id: workflow_id, user_id: user_id)

    new_reductions = reducers.map do |reducer|
      inputs = nil
      priors = nil

      if reducer.reduce_by_user?
        inputs = extracts.user_extracts
        priors = user_reductions.where(reducer_key: reducer.key)
      elsif reducer.reduce_by_subject?
        inputs = extracts.subject_extracts
        priors = subject_reductions.where(reducer_key: reducer.key)
      end

      if reducer.running_reduction? and priors.present?
        inputs = extracts.exact_extracts
      end

      reducer.process(inputs, priors)
    end.flatten

    return if new_reductions == Reducer::NoData or new_reductions.reject{|reduction| reduction == Reducer::NoData}.empty?

    Workflow.transaction do
      new_reductions.each do |reduction|
        next if reduction == Reducer::NoData
        reduction.save!
      end
    end

    new_reductions
  rescue ActiveRecord::StaleObjectError
    raise ReductionConflict "Running Reduction synchronization error in workflow #{ workflow_id } subject #{ subject_id } user #{ user_id }"
  rescue ActiveRecord::RecordNotUnique, PG::UniqueViolation
    sleep 2
    retry unless (tries-=1).zero?
    raise
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

  def check_user_rules(workflow_id, user_id)
    return unless (user_rules.present? and not user_id.blank?)

    rule_bindings = RuleBindings.new(user_reductions(workflow_id, user_id), nil)
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

  def user_reductions(workflow_id, user_id)
    UserReduction.where(workflow_id: workflow_id, user_id: user_id)
  end

  def subject_reductions(workflow_id, subject_id)
    SubjectReduction.where(workflow_id: workflow_id, subject_id: subject_id)
  end
end
