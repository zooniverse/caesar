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
    return [] unless extractors&.present?

    tries ||= 2

    workflow = Workflow.find(classification.workflow_id)

    if workflow.name.blank?
      DescribeWorkflowWorker.perform_async(classification.workflow_id)
    end

    novel_subject = Extract.where(subject_id: classification.subject_id, workflow_id: classification.workflow_id).empty?
    novel_user = classification.user_id.present? && Extract.where(user_id: classification.user_id, workflow_id: classification.workflow_id).empty?

    exception = nil

    extracts = extractors.map do |extractor|
      extract_ok = false
      begin
        data = extractor.process(classification)
        extract_ok = true
      rescue Exception => e
        exception = e
      end

      next unless extract_ok

      extract = Extract.where(
        workflow_id: classification.workflow_id,
        subject_id: classification.subject_id,
        classification_id: classification.id,
        extractor_key: extractor.key,
        project_id: classification.project_id
      ).first_or_initialize

      extract.tap do |an_extract|
        an_extract.user_id = classification.user_id
        an_extract.classification_at = classification.created_at
        an_extract.data = data
      end
    end

    raise StandardError.new('One or more extractors failed', cause: exception) unless exception.blank?

    return if extracts&.compact.blank?

    Workflow.transaction do
      extracts.each do |extract|
        extract.save!
      end
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

  def reduce(reducible_id, subject_id, user_id, extract_ids=[])
    return [] unless reducers&.present?
    retries ||= 2

    filter = { subject_id: subject_id, user_id: user_id }
    if reducible_class.to_s == "Workflow"
      filter[:workflow_id] = reducible_id
    elsif reducible_class.to_s == "Project"
      filter[:project_id] = reducible_id
    end
    extract_fetcher = ExtractFetcher.new(filter).including(extract_ids)

    reduction_filter = { reducible_id: reducible_id, reducible_type: reducible_class.to_s, subject_id: subject_id, user_id: user_id }
    reduction_fetcher = ReductionFetcher.new(reduction_filter)

    # if we don't need to fetch everything, try not to
    if reducers.all?{ |reducer| reducer.running_reduction? }
      extract_fetcher.strategy! :fetch_minimal
    end

    # prefetch all reductions to avoid race conditions with optimistic locking
    if reducers.any?{ |reducer| reducer.running_reduction? }
      reduction_fetcher.load!
    end

    new_reductions = reducers.map do |reducer|
      reducer.process(extract_fetcher.for(reducer.topic), reduction_fetcher.for!(reducer.topic))
    end.flatten

    ActiveRecord::Base.transaction do
      new_reductions.each do |reduction|
        reduction.save!
      end
    end

    new_reductions
  rescue ActiveRecord::StaleObjectError
    retry unless (retries-=1).zero?
    raise ReductionConflict, "Object version mismatch"
  rescue ActiveRecord::RecordNotUnique, PG::UniqueViolation
    retry unless (retries-=1).zero?
    raise ReductionConflict, "Transient uniqueness violation"
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
