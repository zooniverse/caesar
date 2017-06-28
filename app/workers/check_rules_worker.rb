class CheckRulesWorker
  include Sidekiq::Worker
  sidekiq_options retry: 2
  sidekiq_options unique: :until_executing unless Rails.env.test?

  def perform(workflow_id, subject_id)
    workflow = Workflow.find(workflow_id)
    workflow.classification_pipeline.check_rules(workflow_id, subject_id)
  end
end
