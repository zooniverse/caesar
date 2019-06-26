class DeleteClassificationWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'batch'

  def perform(classification_id)
    classification = Classification.find_by_id(classification_id)
    return unless classification

    classification.destroy
  end
end
