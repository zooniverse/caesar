# frozen_string_literal: true

require 'csv'
# Worker to bulk import extracts from csv
class CreateExtractsWorker
  include Sidekiq::Worker

  def perform(csv_filepath, workflow_id)
    @bulk_extracts = []
    UrlDownloader.stream(csv_filepath) do |io|
      puts 'MDY114'
      puts io
      csv = CSV.new(io, headers: true)
      puts csv
      csv.each do |row|
        extract = row.to_hash
        extract[:workflow_id] = workflow_id
        extract[:classification_at] = Time.now
        puts extract
      end
    end

    puts workflow_id
    # CSV.foreach(csv_filepath, headers: true, header_converters: :symbol) do |row|
    #   extract = row.to_hash
    #   # possible that csv will include data for multiple workflows?
    #   extract[:workflow_id] = workflow_id
    #   extract[:classification_at] = Time.now
    #   # testing with ANY int id to bypass not null constraint, but strongly
    #   # thinking of removing not nulll constraint for classification id and
    #   # doing a condition unique constraint for extractor_key,
    #   # classification_id combo only when classification id is not null
    #   extract[:classification_id] = 0 if row.to_hash[:classification_id].nil?
    #   @bulk_extracts << extract
    # end

    # Extract.import @bulk_extracts, validate: false
  end

end
