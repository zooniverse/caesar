# frozen_string_literal: true

require 'csv'
# Worker to bulk import machine learnt extracts from web accessibly located csv
class CreateExtractsWorker
  include Sidekiq::Worker
  sidekiq_options retry: 2

  def perform(csv_filepath, workflow_id)
    workflow = Workflow.find(workflow_id)
    upsert_extracts csv_filepath, workflow
    run_workflow_reducers(workflow) if workflow&.reducers&.any?
    project = Project.find(workflow.project_id)
    run_project_reducers(project) if project&.has_reducers?
  end

  private

  def upsert_extracts(csv_filepath, workflow_id)
    UrlDownloader.stream(csv_filepath) do |io|
      csv = CSV.new(io, headers: true)
      csv.each do |row|
        hashed_row = row.to_hash
        upsert_subject hashed_row['subject_id']
        extract = init_extract hashed_row, workflow_id
        set_extract_data_from_row hashed_row, extract
        extract.save!
      end
    end
  end

  def upsert_subject(subject_id)
    s = Subject.where(id: subject_id).first_or_initialize
    s.metadata = {} if s.metadata.nil?
    s.save!
  end

  def init_extract(hashed_row, workflow)
    Extract.where(
      workflow_id: workflow.id,
      subject_id: hashed_row['subject_id'],
      extractor_key: hashed_row['extractor_key'],
      workflow_version: hashed_row['workflow_version'],
      project_id: workflow.project_id,
      machine_data: true,
      classification_id: nil
    ).first_or_initialize
  end

  def set_extract_data_from_row(hashed_row, extract)
    puts hashed_row['data']
    extract.data = if valid_json?(hashed_row['data'])
                     JSON.parse hashed_row['data']
                   else
                     hashed_row['data']
                   end
    extract.classification_at = Time.now unless extract.classification_at.present?
    extract
  end

  def valid_json?(str)
    !!JSON.parse(str)
  rescue JSON::ParserError
    false
  end

  def run_workflow_reducers(workflow)
    workflow.rerun_reducers
  end

  def run_project_reducers(project)
    project.rerun_reducers
  end
end
