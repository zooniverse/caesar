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
    tries ||= 2

    extractors.each do |extractor|
      known_subject = Extract.exists?(subject_id: classification.subject_id, workflow_id: classification.workflow_id)
      known_user = Extract.exists?(user_id: classification.subject_id, workflow_id: classification.workflow_id)

      data = extractor.process(classification)

      extract = Extract.where(workflow_id: classification.workflow_id, subject_id: classification.subject_id, classification_id: classification.id, extractor_key: extractor.key).first_or_initialize
      extract.user_id = classification.user_id
      extract.classification_at = classification.created_at
      extract.data = data
      extract.save!

      unless known_subject
        FetchClassificationsWorker.perform_async(classification.workflow_id, classification.subject_id, FetchClassificationsWorker.fetch_for_subject)
      end

      unless known_user
        FetchClassificationsWorker.perform_async(classification.workflow_id, classification.user_id, FetchClassificationsWorker.fetch_for_user)
      end

      extract
    end
  rescue ActiveRecord::RecordNotUnique, PG::UniqueViolation
    sleep 2
    retry unless (tries-=1).zero?
    raise
  end

  def reduce(workflow_id, subject_id, user_id)
    tries ||= 2

    extracts = ExtractFetcher.new(workflow_id, subject_id, user_id)

    reducers.map do |reducer|
      data = if reducer.reduce_by_subject?
        reducer.process(extracts.subject_extracts)
      elsif reducer.reduce_by_user?
        reducer.process(extracts.user_extracts)
      else
        Reducer::NoData
      end

      return if data == Reducer::NoData

      data.map do |subgroup, datum|
        next if data == Reducer::NoData

        reduction = if reducer.reduce_by_subject?
            SubjectReduction.where(
              workflow_id: workflow_id,
              subject_id: subject_id,
              reducer_key: reducer.key,
              subgroup: subgroup).first_or_initialize
          elsif reducer.reduce_by_user?
            UserReduction.where(
              workflow_id: workflow_id,
              user_id: user_id,
              reducer_key: reducer.key,
              subgroup: subgroup).first_or_initialize
          else
            nil
          end

        reduction.data = datum
        reduction.subgroup = subgroup
        reduction.save!

        reduction
      end
    end.flatten
  rescue ActiveRecord::RecordNotUnique, PG::UniqueViolation
    sleep 2
    retry unless (tries-=1).zero?
    raise
  end

  def check_rules(workflow_id, subject_id, user_id)
    return unless subject_rules.present? or (user_rules.present? and not user_id.blank?)

    subject = Subject.find(subject_id)

    rule_bindings = RuleBindings.new(subject_reductions(workflow_id, subject_id), subject)
    subject_rules.each do |rule|
      rule.process(subject_id, rule_bindings)
    end

    rule_bindings = RuleBindings.new(user_reductions(workflow_id, user_id), nil)
    user_rules.each do |rule|
      rule.process(user_id, rule_bindings)
    end
  end

  private

  def user_reductions(workflow_id, user_id)
    UserReduction.where(workflow_id: workflow_id, user_id: user_id)
  end

  def subject_reductions(workflow_id, subject_id)
    SubjectReduction.where(workflow_id: workflow_id, subject_id: subject_id)
  end
end
