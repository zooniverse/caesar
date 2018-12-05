class CheckRulesWorker
  include Sidekiq::Worker
  sidekiq_options retry: 2
  sidekiq_options unique: :until_executing unless Rails.env.test?
  sidekiq_options queue: 'internal'

  def perform(reducible_id, reducible_type, subject_id, user_id = nil)
    reducible = reducible_type.constantize.find(reducible_id)

    return if reducible.class.name.demodulize=='Workflow' && reducible.paused?

    reducible.rules_runner.check_rules(subject_id, user_id)
  end
end
