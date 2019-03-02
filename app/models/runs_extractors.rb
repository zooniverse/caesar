class RunsExtractors
  attr_reader :extractors

  def initialize(extractors)
    @extractors = extractors
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

    exceptions = []

    extracts = extractors.map do |extractor|
      extract_ok = false
      begin
        data = extractor.process(classification)
        extract_ok = true
      rescue Exception => e
        exceptions.push(e)
      end

      next unless extract_ok

      extract = Extract.where(
        workflow_id: classification.workflow_id,
        subject_id: classification.subject_id,
        classification_id: classification.id,
        extractor_key: extractor.key
      ).first_or_initialize

      extract.tap do |an_extract|
        an_extract.user_id = classification.user_id
        an_extract.classification_at = classification.created_at
        an_extract.project_id = classification.project_id
        an_extract.data = data
      end
    end

    exceptions.each do |exception|
      Rollbar.log('error', exception)
    end

    raise ExtractionFailed.new('One or more extractors failed') unless exceptions.blank?

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
end
