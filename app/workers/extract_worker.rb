class ExtractWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5
  sidekiq_retry_in do |count|
    (count ** 8) + 15 + (rand(30) * count + 1)
  end

  # second param accepted for backwards compat reasons, remove later
  def perform(classification_or_legacy_workflow_id, legacy_classification_data=nil)
    if legacy_classification_data.present?
      workflow_id = classification_or_legacy_workflow_id
      classification_data = legacy_classification_data

      workflow = Workflow.find(workflow_id)
      classification = Classification.new(classification_data)
      extract = workflow.classification_pipeline.extract(classification)

      return if extract == Extractor::NoData

      ReduceWorker.perform_async(workflow_id, classification.subject_id)
      workflow.webhooks.process(:new_extraction, extract.data) if workflow.subscribers?
    else
      classification_id = classification_or_legacy_workflow_id

      classification = Classification.find(classification_id)
      workflow = classification.workflow
      extract = workflow.classification_pipeline.extract(classification)

      return if extract == Extractor::NoData

      ReduceWorker.perform_async(workflow_id, classification.subject_id)
      workflow.webhooks.process(:new_extraction, extract.data) if workflow.subscribers?
    end
  end
end
