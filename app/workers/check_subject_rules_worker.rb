class CheckSubjectRulesWorker
  include Sidekiq::Worker
  sidekiq_options retry: 2
  sidekiq_options lock: :until_executing unless Rails.env.test?
  sidekiq_options queue: 'internal'

  def perform(reducible_id, reducible_type, subject_id)
    reducible = reducible_type.constantize.find(reducible_id)

    # if reducible is only paused, continue processing everything but extracts
    # if reducible is halted, do not process anything
    return if reducible.halted?

    rules_runner = RunsSubjectRules.new(reducible, reducible.subject_rules.rank(:row_order), reducible.rules_applied)
    rules_runner.check_rules(subject_id)
  end
end
