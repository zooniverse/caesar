class FetchClassificationsWorker
  include Sidekiq::Worker

  sidekiq_options unique: :until_executing unless Rails.env.test?

  def perform(subject_id, workflow_id)
    classifications = Effects.panoptes.get_subject_classifications(subject_id, workflow_id)["classifications"]
    process_classifications(workflow_id, classifications)
  end

  def process_classifications(workflow_id, classifications)
    return unless classifications

    classifications.each do |attributes|
      classification = Classification.find_or_initialize_by(id: attributes["id"])
      classification.attributes = attributes
      classification.save!

      ExtractWorker.perform_async(classification.id)
    end
  end
end
