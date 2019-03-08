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

    has_errors = false

    extracts = extractors.map do |extractor|
      extract_ok = false
      begin
        data = extractor.process(classification)
        extract_ok = true
      rescue Exception => e
        Rollbar.log('error', e)
        has_errors = true
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

    raise Extractor::ExtractionFailed.new('One or more extractors failed') if has_errors

    return if extracts&.compact.blank?

    Workflow.transaction do
      extracts.each do |extract|
        extract.save!
      end
    end

    extracts
  rescue ActiveRecord::RecordNotUnique, PG::UniqueViolation
    sleep 2
    retry unless (tries-=1).zero?
    raise
  end
end
