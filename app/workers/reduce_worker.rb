class ReduceWorker
  include Sidekiq::Worker

  def perform(workflow_id, subject_id)
    workflow = Workflow.find(workflow_id)
    workflow.classification_pipeline.reduce(workflow_id, subject_id)

    CheckRulesWorker.perform_async(workflow_id, subject_id)
  end
end
