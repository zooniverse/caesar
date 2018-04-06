class ReduceWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5
  sidekiq_options unique: :until_executing unless Rails.env.test?
  sidekiq_options queue: 'internal'
  sidekiq_retry_in do |count|
    (count ** 8) + 15 + (rand(30) * count + 1)
  end

  def perform(workflow_id, subject_id, user_id, extract_ids = [])
    workflow = Workflow.find(workflow_id)

    begin
      reductions = workflow.classification_pipeline.reduce(workflow_id, subject_id, user_id, extract_ids)
    rescue ClassificationPipeline::ReductionConflict
      ReduceWorker.perform_async(workflow_id, subject_id, user_id, extract_ids)
      return
    end

    return if reductions.blank?

    CheckRulesWorker.perform_async(workflow_id, subject_id, user_id)
    reductions.each do |item|
      workflow.webhooks.process(:new_reduction, item) if workflow.subscribers?
    end
  end
end
