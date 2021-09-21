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
        extract.data = hashed_row['data']
        extract.classification_at = Time.now unless extract.classification_at.present?
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

  def run_workflow_reducers(workflow)
    puts "MDY114 REDUCERS!"
    workflow.rerun_reducers
  end

  def run_project_reducers(project)
    project.rerun_reducers
  end
end
