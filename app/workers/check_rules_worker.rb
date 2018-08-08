class CheckRulesWorker
  include Sidekiq::Worker
  sidekiq_options retry: 2
  sidekiq_options unique: :until_executing unless Rails.env.test?
  sidekiq_options queue: 'internal'

  def perform(reducible_id, reducible_type, subject_id, user_id = nil)
    reducible = reducible_type.constantize.find(reducible_id)
    reducible.classification_pipeline.check_rules(reducible_id, subject_id, user_id)
  end
end
