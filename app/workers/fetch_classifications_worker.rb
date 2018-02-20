class FetchClassificationsWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'batch'

 # note: because this isn't an ApplicationRecord subclass,
  # we can't simply use enum
  @@FetchForSubject = 0.freeze
  @@FetchForUser = 1.freeze

  def self.fetch_for_subject
    @@FetchForSubject
  end

  def self.fetch_for_user
    @@FetchForUser
  end

  sidekiq_options unique: :until_executing unless Rails.env.test?

  def perform(workflow_id, object_id, object_type)
    classifications = case object_type
    when @@FetchForSubject
      Effects.panoptes.get_subject_classifications(object_id, workflow_id)["classifications"]
    when @@FetchForUser
      # Effects.panoptes.get_user_classifications(object_id, workflow_id)["classifications"]
      nil
    else
      nil
    end

    process_classifications(workflow_id, classifications)
  end

  def process_classifications(workflow_id, classifications)
    return unless classifications

    classifications.each do |attributes|
      attributes["workflow_version"] ||= attributes["metadata"]["workflow_version"]
      classification = Classification.upsert(attributes)
      ExtractWorker.perform_async(classification.id)
    end
  end
end
