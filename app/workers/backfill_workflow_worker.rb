class BackfillWorkflowWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'batch'

  def perform(workflow_id, duration = 24.hours)
    workflow = Workflow.find(workflow_id)


    panoptes_api.paginate('/subjects', { workflow_id: workflow.id }) do |_, page|
      page["subjects"].each do |attrs|
        subject = Subject.update_cache(attrs)
        delay = rand(duration.to_i).seconds
        FetchClassificationsWorker.perform_in(delay, workflow.id, subject.id, FetchClassificationsWorker.fetch_for_subject)
      end
    end
  end

  def panoptes_api
    Effects.panoptes.panoptes
  end
end
