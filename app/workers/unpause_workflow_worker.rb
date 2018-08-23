class UnpauseWorkflowWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'batch'

  def perform(workflow_id, duration = 3.hours)
    workflow = Workflow.find(workflow_id)
    return unless workflow.active?

    classification_ids = Classification.where(workflow_id: workflow_id).pluck(:id)

    classification_ids.each do |id|
      delay = rand(duration.to_i).seconds
      ExtractWorker.perform_in(delay, id)
    end
  end

  def panoptes_api
    Effects.panoptes.panoptes
  end
end
