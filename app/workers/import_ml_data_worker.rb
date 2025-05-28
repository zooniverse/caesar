# frozen_string_literal: true

require 'csv'
# Worker to bulk import Machine Learnt (ML) extracts from web accessibly located csv
class ImportMlDataWorker
  include Sidekiq::Worker

  def perform(csv_filepath, workflow_id)
    workflow = Workflow.find(workflow_id)
    UrlDownloader.stream(csv_filepath) do |io|
      csv = CSV.new(io, headers: true)
      upsert_data_from_csv csv, workflow
    end
    run_workflow_reducers(workflow) if workflow&.reducers&.any?
    project = Project.where(id: workflow.project_id).first
    run_project_reducers(project) if project&.has_reducers?
  end

  private

  def upsert_data_from_csv(csv, workflow)
    csv.each do |row|
      hashed_row = row.to_hash
      if valid_find_params(hashed_row)
        upsert_subject hashed_row['subject_id']
        upsert_extract hashed_row, workflow
      end
    end
  end

  def upsert_extract(hashed_row, workflow)
    extract = init_extract hashed_row, workflow
    set_extract_data_from_row hashed_row, extract
    extract.save!
  end

  def upsert_subject(subject_id)
    Subject.where(id: subject_id).first_or_create
  end

  def init_extract(hashed_row, workflow)
    extract_find_params = create_find_params hashed_row, workflow
    Extract.where(
      extract_find_params
    ).first_or_initialize
  end

  def valid_find_params(hashed_row)
    [hashed_row['subject_id'], hashed_row['extractor_key']].all?
  end

  def create_find_params(hashed_row, workflow)
    extract_find_params = {
      machine_data: true,
      workflow_id: workflow.id,
      classification_id: nil
    }
    extract_find_params['subject_id'] = hashed_row['subject_id']
    extract_find_params['extractor_key'] = hashed_row['extractor_key']
    extract_find_params['workflow_version'] = hashed_row['workflow_version'] if hashed_row['workflow_version']
    extract_find_params.compact
  end

  def set_extract_data_from_row(hashed_row, extract)
    extract.data = parse_extract_data hashed_row
    extract.classification_at = Time.now unless extract.classification_at.present?
    extract
  end

  def parse_extract_data(hashed_row)
    JSON.parse hashed_row['data']
  rescue JSON::ParserError
    hashed_row['data']
  end

  def run_workflow_reducers(workflow)
    workflow.rerun_reducers
  end

  def run_project_reducers(project)
    project.rerun_reducers
  end
end
