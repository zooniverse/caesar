
class DescribeWorkflowWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'batch'
  sidekiq_options unique: :until_executed unless Rails.env.test?

  def perform(workflow_id)
    light = Stoplight("describe-workflow-#{workflow_id}") do
      workflow = Workflow.find(workflow_id)

      return if workflow.paused?
      return unless workflow.name.blank? || workflow.project_name.blank?

      panoptes_workflow = Effects.panoptes.workflow(workflow_id)
      panoptes_project = Effects.panoptes.project(workflow.project_id)

      workflow.name = panoptes_workflow['display_name']
      workflow.project_name = panoptes_project['display_name']

      workflow.save!
      Workflow.where(project_id: workflow.project_id).update(project_name: workflow.project_name)
    end

    light.run
  end
end