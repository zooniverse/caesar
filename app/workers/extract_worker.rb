class ExtractWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5
  sidekiq_options queue: 'internal'
  sidekiq_retry_in do |count|
    (count ** 8) + 15 + (rand(30) * count + 1)
  end

  def perform(classification_id)
    classification = Classification.find(classification_id)

    workflow = classification.workflow
    extracts = workflow.classification_pipeline.extract(classification)
    extracts = extracts.select { |extract| extract != Extractor::NoData }

    classification.destroy

    if extracts.present?
      ids = extracts.map(&:id)
      ReduceWorker.perform_async(classification.workflow_id, "Workflow", classification.subject_id, classification.user_id, ids)

      project = Project.find_by_id(workflow.project_id)
      if project && project.has_reducers?
        ReduceWorker.perform_async(classification.project_id, "Project", classification.subject_id, classification.user_id, ids)
      end
    end
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
