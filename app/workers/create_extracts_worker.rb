# frozen_string_literal: true

require 'csv'
# Worker to bulk import extracts from csv
class CreateExtractsWorker
  include Sidekiq::Worker
  BATCH_SIZE = 100

  def perform(csv_filepath, workflow_id)
    @bulk_extracts = []
    CSV.foreach(csv_filepath, headers: true, header_converters: :symbol) do |row|
      extract = row.to_hash
      # possible that csv will include data for multiple workflows?
      extract[:workflow_id] = workflow_id if row.to_hash[:workflow_id].nil?
      extract[:classification_at] = Time.now
      # testing with ANY int id to bypass not null constraint, but strongly
      # thinking of removing not nulll constraint for classification id and
      # doing a condition unique constraint for extractor_key,
      # classification_id combo only when classification id is not null
      extract[:classification_id] = 0 if row.to_hash[:classification_id].nil?
      @bulk_extracts << extract
      bulk_enqueue_current_batch if @bulk_extracts.length > BATCH_SIZE
    end
    bulk_enqueue_current_batch
  end

  private

  def bulk_enqueue_current_batch
    Extract.import @bulk_extracts, validate: false
    @bulk_extracts = []
  end
end
