# frozen_string_literal: true

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

      CSV.foreach(csv_filepath, headers: true, header_converters: :symbol) do |row|
        extract = row.to_hash
        extract[:workflow_id] = workflow_id
        extract[:classification_at] = DateTime.now
        extract[:classification_id] = workflow_id
        @bulk_extracts << extract
      end
      @bulk_extracts
    #   bulk_enqueue_current_batch
    end

    private

    def bulk_enqueue_current_batch
      byebug
      CreateExtractsWorker.perform_async(@bulk_extracts)
      @bulk_extracts = []
    end
  end
end
