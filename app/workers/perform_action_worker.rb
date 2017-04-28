class PerformActionWorker
  include Sidekiq::Worker

  def perform(action_id)
    action = Action.find(action_id)
    action.perform
  end
end
