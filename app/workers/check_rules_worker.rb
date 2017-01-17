class CheckRulesWorker
  include Sidekiq::Worker

  def perform(workflow_id, subject_id)
    workflow = Workflow.find(workflow_id)
    workflow.classification_pipeline.check_rules(workflow_id, subject_id)
  end
end
