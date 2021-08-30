# frozen_string_literal: true

require 'csv'
# Worker to bulk import extracts from csv
class CreateExtractsWorker
  include Sidekiq::Worker

  def perform(csv_filepath, workflow_id)
    @bulk_extracts = []
    init_extracts csv_filepath, workflow_id
    Extract.import @bulk_extracts, validate: false, all_or_none: true
  end

  private

  def init_extracts(csv_filepath, workflow_id)
    UrlDownloader.stream(csv_filepath) do |io|
      csv = CSV.new(io, headers: true)
      csv.each do |row|
        extract = row.to_hash
        extract[:workflow_id] = workflow_id
        extract[:classification_at] = Time.now
        @bulk_extracts << extract
      end
    end
  end
end
