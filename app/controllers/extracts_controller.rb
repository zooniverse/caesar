class ExtractsController < ApplicationController
  before_action :authenticate!

  def index
    extracts = Extract.where(workflow_id: params[:workflow_id], subject_id: params[:subject_id])
    render json: extracts
  end

  def update
    extract = Extract.find_or_initialize_by(workflow_id: workflow.id,
                                            extractor_id: extractor.id,
                                            subject_id: subject.id)
    extract.update! extract_params

    render json: extract
  end

  private

  def authenticate!
    head :forbidden unless workflow.present?
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

  def extract_params
    params.require(:extract).permit(:classification_id, :classification_at, :user_id, :data).tap do |whitelisted|
      whitelisted[:data] = params[:extract][:data].permit!
    end
  end
end
