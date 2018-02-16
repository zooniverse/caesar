class PerformExtraction
  def initialize(workflow)
    @workflow = workflow
  end

  def extract(classification)
    tries ||= 2

    enqueue_data_loads(classification) do
      extractors.each do |extractor|
        data = extractor.process(classification)

        extract = Extract.where(workflow_id: classification.workflow_id, subject_id: classification.subject_id, classification_id: classification.id, extractor_key: extractor.key).first_or_initialize
        extract.user_id = classification.user_id
        extract.classification_at = classification.created_at
        extract.data = data
        extract.save!

        extract
      end
    end
  rescue ActiveRecord::RecordNotUnique, PG::UniqueViolation
    sleep 2
    retry unless (tries-=1).zero?
    raise
  end

  private

  def enqueue_data_loads(classification)
    known_subject = Extract.exists?(subject_id: classification.subject_id, workflow_id: classification.workflow_id)
    known_user = Extract.exists?(user_id: classification.subject_id, workflow_id: classification.workflow_id)

    yield.tap do
      if extractors.present?
        unless known_subject
          FetchClassificationsWorker.perform_async(classification.workflow_id, classification.subject_id, FetchClassificationsWorker.fetch_for_subject)
        end

        unless known_user
          FetchClassificationsWorker.perform_async(classification.workflow_id, classification.user_id, FetchClassificationsWorker.fetch_for_user)
        end
      end
    end
  end

  def extractors
    @workflow.extractors
  end
end
