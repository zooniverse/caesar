class PerformUserActionWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'external'

  def perform(action_id)
    action = UserAction.find(action_id)
    action.perform
  end
end
