class ReduceWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5
  sidekiq_options unique: :until_and_while_executing, unique_args: :unique_args unless Rails.env.test?
  sidekiq_options queue: 'internal'
  sidekiq_retry_in do |count|
    (count ** 8) + 15 + (rand(30) * count + 1)
  end

  def self.unique_args(args)
    [args[0], args[1], args[2]]
  end

  def perform(workflow_id, subject_id, user_id, extract_ids = [])
    workflow = Workflow.find(workflow_id)

    reductions = workflow.classification_pipeline.reduce(workflow_id, subject_id, user_id, extract_ids)

    return if reductions.blank?

    CheckRulesWorker.perform_async(workflow_id, subject_id, user_id)
    reductions.each do |item|
      workflow.webhooks.process(:new_reduction, item) if workflow.subscribers?
    end
  end
end
