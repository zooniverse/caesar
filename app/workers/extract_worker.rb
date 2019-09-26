class ExtractWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5
  sidekiq_options queue: 'internal'
  sidekiq_retry_in do |count|
    (count ** 8) + 15 + (rand(30) * count + 1)
  end

  def perform(classification_id, reduce_after_extraction=nil)
    if reduce_after_extraction.nil?
      reduce_after_extraction = true
    end
    classification = Classification.find_by_id(classification_id)
    return unless classification

    workflow = classification.workflow

    # when deciding whether to run extractors, we need to handle both cases the same way, by doing nothing;
    # when deciding whether to reduce or to run rules, they need to be handled in different ways
    # checking to see if the workflow is active implies that it's not paused or halted
    return unless workflow.active?

    extracts = workflow.extractors_runner.extract(classification, and_reduce: reduce_after_extraction)
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
