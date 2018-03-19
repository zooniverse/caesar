class ReduceWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5
  sidekiq_options unique: :until_executing unless Rails.env.test?
  sidekiq_options queue: 'internal'
  sidekiq_retry_in do |count|
    (count ** 8) + 15 + (rand(30) * count + 1)
  end

  def perform(reducible_class, reducible_id, subject_id, user_id)
    reducible = reducible_class.find(reducible_id)
    reductions = reducible.classification_pipeline.reduce(reducible_id, reducible_class, subject_id, user_id)

    return if reductions == Reducer::NoData

    CheckRulesWorker.perform_async(workflow_id, subject_id, user_id)
    reductions.each do |datum|
      workflow.webhooks.process(:new_reduction, datum) if workflow.subscribers?
    end
  end
end
