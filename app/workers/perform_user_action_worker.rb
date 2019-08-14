class PerformUserActionWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'external'

  def perform(action_id)
    action = UserAction.find(action_id)

    # if reducible is only paused, continue processing everything but extracts
    # if reducible is halted, do not process anything
    return if action.workflow.halted?

    action.perform
  end
end
