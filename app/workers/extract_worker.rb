class ExtractWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5
  sidekiq_retry_in do |count|
    (count ** 8) + 15 + (rand(30) * count + 1)
  end

  # second param accepted for backwards compat reasons, remove later
  def perform(classification_id)
    classification = Classification.find(classification_id)

    workflow = classification.workflow
    extracts = workflow.classification_pipeline.extract(classification)
    extracts = extracts.select { |extract| extract != Extractor::NoData }

    classification.destroy

    if extracts.present?
      ReduceWorker.perform_async(classification.workflow_id, classification.subject_id)
    end

    if workflow.subscribers?
      extracts.each do |extract|
        workflow.webhooks.process(:new_extraction, extract.data) if workflow.subscribers?
      end
    end
  end
end
