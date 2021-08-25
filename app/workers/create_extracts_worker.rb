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
      extract[:workflow_id] = workflow_id unless workflow_id.nil?
      extract[:classification_at] = Time.now
      extract[:classification_id] = workflow_id
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
