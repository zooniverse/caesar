class PerformUserActionWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'external'

  def perform(action_id)
    action = SubjectAction.find(action_id)
    action.perform
  end
end
