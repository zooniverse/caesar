class ExtractWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5
  sidekiq_options queue: 'internal'
  sidekiq_retry_in do |count|
    (count ** 8) + 15 + (rand(30) * count + 1)
  end

  def perform(classification_id)
    classification = Classification.find_by_id(classification_id)
    return unless classification

    workflow = classification.workflow

    # if reducible is only paused, continue processing everything but extracts
    # if reducible is halted, do not process anything
    return unless workflow.active?

    extracts = workflow.extractors_runner.extract(classification, and_reduce: true)
    DeleteClassificationWorker.perform_in(rand(30.minutes.to_i).seconds, classification.id)

    extracts
  rescue ActiveRecord::RecordNotFound => e
    if Extract.where(classification_id: classification_id).any?
      # This will sometimes happen in the following sequence of events:
      #
      # A: ExtractWorker begins
      # B: FetchClassificationsWorker begins
      # B: FetchClassificationsWorker upserts fetched classification (with same ID)
      # A: ExtractWorker finishes and deletes classification
      # B: FetchClassificationsWorker enqueues ExtractWorker
      #
      # This specific sequence is harmless and should be ignored.
      true
    else
      raise e
    end
  end
end
