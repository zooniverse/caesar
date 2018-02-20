class CheckRulesWorker
  include Sidekiq::Worker
  sidekiq_options retry: 2
  sidekiq_options unique: :until_executing unless Rails.env.test?
  sidekiq_options queue: 'internal'

  def perform(workflow_id, subject_id, user_id = nil)
    workflow = Workflow.find(workflow_id)
    workflow.classification_pipeline.check_rules(workflow_id, subject_id, user_id)
  end
end
