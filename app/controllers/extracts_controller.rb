class ExtractsController < ApplicationController

  def index
    extracts = Extract.where(workflow_id: params[:workflow_id], subject_id: params[:subject_id])
    render json: extracts
  end

  def update
    extract = Extract.find_or_initialize_by(workflow_id: workflow.id,
                                            extractor_id: extractor.id,
                                            classification_id: classification_id)
    extract.update! extract_params

    ReduceWorker.perform_async(workflow.id, subject.id) if workflow.configured?

    workflow.webhooks.process(:updated_extraction, data) if workflow.subscribers?

    render json: extract
  end

  private

  def authorized?
    workflow.present?
  end

  def workflow
    @workflow ||= Workflow.accessible_by(credential).find(params[:workflow_id])
  end

  def extractor
    workflow.extractors[params[:extractor_id]]
  end

  def subject
    @subject ||= Subject.find(params[:extract][:subject_id])
  end

  def classification_id
    params[:extract][:classification_id]
  end

  def data
    params[:extract][:data]
  end

  def extract_params
    params.require(:extract).permit(:classification_id, :classification_at, :user_id, :data, :subject_id).tap do |whitelisted|
      whitelisted[:data] = params[:extract][:data].permit!
    end
  end
end
