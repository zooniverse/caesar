class FetchClassificationsWorker
  include Sidekiq::Worker

  sidekiq_options unique: :until_executing

  def perform(subject_id, workflow_id)
    classifications = Effects.panoptes.get_subject_classifications(subject_id, workflow_id)["classifications"]
    process_classifications(workflow_id, classifications)
  end

  def process_classifications(workflow_id, classifications)
    return unless classifications

    classifications.each do |classification|
      ExtractWorker.perform_async(workflow_id, classification)
    end
  end
end
