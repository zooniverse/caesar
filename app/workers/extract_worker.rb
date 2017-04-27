class ExtractWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5
  sidekiq_retry_in do |count|
    (count ** 8) + 15 + (rand(30) * count + 1)
  end

  def perform(workflow_id, classification_data)
    workflow = Workflow.find(workflow_id)
    classification = Classification.new(classification_data)
    workflow.classification_pipeline.extract(classification)

    ReduceWorker.perform_async(workflow_id, classification.subject_id)
  end
end
