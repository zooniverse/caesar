class CheckRulesWorker
  include Sidekiq::Worker
  sidekiq_options retry: 2
  sidekiq_options lock: :until_executing unless Rails.env.test?
  sidekiq_options queue: 'internal'

  # TODO: Remove this class after CheckSubjectRulesWorker and CheckUserRulesWorker have been deployed
  # and any instances of this worker are gone from the queues.
  def perform(reducible_id, reducible_type, subject_id, user_id = nil)
    reducible = reducible_type.constantize.find(reducible_id)

    # if reducible is only paused, continue processing everything but extracts
    # if reducible is halted, do not process anything
    return if reducible.halted?

    reducible.rules_runner.check_rules(subject_id, user_id)
  end
end
