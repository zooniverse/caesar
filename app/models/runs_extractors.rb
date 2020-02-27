class RunsExtractors
  attr_reader :extractors

  def initialize(extractors)
    @extractors = extractors
  end

  def has_external?
    extractors.any?{ |extractor| extractor.type == 'Extractors::ExternalExtractor' }
  end

  def extract(classification, and_reduce: false)
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
        ErrorLogger.report(e)
        has_errors = true
      end

      next unless extract_ok
      next data if data == Extractor::NoData

      extract = Extract.where(
        workflow_id: classification.workflow_id,
        subject_id: classification.subject_id,
        classification_id: classification.id,
        extractor_key: extractor.key
      ).first_or_initialize

      extract.tap do |an_extract|
        an_extract.workflow_version = classification.workflow_version
        an_extract.user_id = classification.user_id
        an_extract.classification_at = classification.created_at
        an_extract.project_id = classification.project_id
        an_extract.data = data
      end
    end

    raise Extractor::ExtractionFailed.new('One or more extractors failed') if has_errors

    extracts = extracts&.select{ |e| e != Extractor::NoData }&.compact
    return if extracts&.blank?

    Workflow.transaction do
      extracts.each do |extract|
        extract.save!
      end
    end

    if and_reduce
      extracts = extracts.select { |extract| extract != Extractor::NoData }
      return if extracts.empty?

      ids = extracts.map(&:id)

      if workflow&.reducers.any?
        worker = if workflow.has_external_reducers?
          ReduceWorkerExternal
        else
          ReduceWorker
        end

        if workflow.custom_queue_name.present?
          worker.set(queue: workflow.custom_queue_name)
                .perform_async(classification.workflow_id, 'Workflow', classification.subject_id, classification.user_id, ids)
        else
          worker.perform_async(classification.workflow_id, 'Workflow', classification.subject_id, classification.user_id, ids)
        end
      end

      project = Project.find_by_id(classification.project_id)
      if project&.has_reducers?
        worker = if project.has_external_reducers?
          ReduceWorkerExternal
        else
          ReduceWorker
        end

        if project.custom_queue_name.present?
          worker.set(queue: project.custom_queue_name)
                .perform_async(classification.workflow_id, 'Workflow', classification.subject_id, classification.user_id, ids)
        else
          worker.perform_async(classification.workflow_id, 'Workflow', classification.subject_id, classification.user_id, ids)
        end

      end
    end

    extracts
  rescue ActiveRecord::RecordNotUnique, PG::UniqueViolation
    sleep 2
    retry unless (tries-=1).zero?
    raise
  end
end
