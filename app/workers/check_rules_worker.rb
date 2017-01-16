class CheckRulesWorker
  include Sidekiq::Worker

  def perform(workflow_id, classification_data)
    workflow = Workflow.find(workflow_id)
    classification = Classification.new(classification_data)

    workflow.classification_pipeline.check_rules(classification)
  end
end
