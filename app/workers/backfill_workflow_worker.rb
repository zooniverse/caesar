class BackfillWorkflowWorker
  include Sidekiq::Worker

  def perform(workflow_id)
    workflow = Workflow.find(workflow_id)

    panoptes_api.paginate("/subjects", workflow_id: workflow.id) do |page|
      page["subjects"].each do |attrs|
        subject = Subject.upsert(attrs)
        FetchClassificationsWorker.perform_async(subject.id, workflow.id)
      end
    end
  end

  def panoptes_api
    Effects.panoptes.panoptes
  end
end
