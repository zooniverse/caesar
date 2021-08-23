require 'csv'

module Importers
  class UnknownImpoter < StandardError; end

  class ExtractCsvImporter
    attr_reader :workflow_id

    def initialize(params)
      @workflow_id = params[:workflow_id]
    end

    def run(csv_filepath)
      @bulk_extracts = []
      CSV.foreach(csv_filepath) do |row|
        bulk_extracts << row
      end
      bulk_enqueue_current_batch
    end

    private

    def batch
      @batch ||= Sidekiq::Batch.new
    end

    def bulk_enqueue_current_batch
      CreateExtractsWorker.push_bulk(bulk_extracts) do |extract|
        [extract, workflow_id]
      end
      @bulk_extracts = []
    end
  end
end