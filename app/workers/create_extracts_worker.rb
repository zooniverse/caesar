# frozen_string_literal: true

require 'csv'
# Worker to bulk import machine learnt extracts from web accessibly located csv
class CreateExtractsWorker
  include Sidekiq::Worker
  sidekiq_options retry: 2

  def perform(csv_filepath, workflow_id)
    upsert_extracts csv_filepath, workflow_id
    # todo run Reducers check if worklow has reducers 
    # if !result.failed_instances.empty?
    # send email
  end

  private

  def upsert_extracts(csv_filepath, workflow_id)
    UrlDownloader.stream(csv_filepath) do |io|
      csv = CSV.new(io, headers: true)
      csv.each do |row|
        hashed_row = row.to_hash
        extract = init_extract hashed_row, workflow_id
        extract.save!
      end
    end
  end

  def init_extract(hashed_row, workflow_id)
    extract = Extract.where(
      workflow_id: workflow_id,
      subject_id: hashed_row['subject_id'],
      extractor_key: hashed_row['extractor_key'],
      workflow_version: hashed_row['workflow_version'],
      project_id: workflow(workflow_id).project_id,
      machine_data: true,
      classification_id: nil
    ).first_or_initialize

    extract.data = hashed_row['data']
    extract.classification_at = Time.now unless extract.classification_at.present?
    extract
  end

  def workflow(workflow_id)
    Workflow.find(workflow_id)
  end
end
