class PerformUserActionWorker
  include Sidekiq::Worker

  def perform(action_id)
    action = SubjectAction.find(action_id)
    action.perform
  end
end
