class BackfillWorkflowWorker
  include Sidekiq::Worker

  def perform(workflow_id, duration = 24.hours)
    workflow = Workflow.find(workflow_id)

    panoptes_api.paginate("/subjects", workflow_id: workflow.id) do |page|
      page["subjects"].each do |attrs|
        subject = Subject.update_cache(attrs)
        delay = rand(duration.to_i).seconds
        FetchClassificationsWorker.perform_in(delay, subject.id, workflow.id)
      end
    end
  end

  def panoptes_api
    Effects.panoptes.panoptes
  end
end
