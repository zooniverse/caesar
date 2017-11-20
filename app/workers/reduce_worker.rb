class ReduceWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5
  sidekiq_options unique: :until_executing unless Rails.env.test?
  sidekiq_retry_in do |count|
    (count ** 8) + 15 + (rand(30) * count + 1)
  end

  def perform(workflow_id, subject_id, user_id)
    workflow = Workflow.find(workflow_id)
    reductions = workflow.classification_pipeline.reduce(workflow_id, subject_id, user_id)

    return if reductions == Reducer::NoData

    CheckRulesWorker.perform_async(workflow_id, subject_id)
    reductions.each do |datum|
      workflow.webhooks.process(:new_reduction, datum) if workflow.subscribers?
    end
  end
end
