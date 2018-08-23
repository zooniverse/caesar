class PerformSubjectActionWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'external'

  def perform(action_id)
    action = SubjectAction.find(action_id)
    return if action.workflow.paused?
    action.perform
  end
end
