class ExtractsController < ApplicationController
  def index
    extracts = policy_scope(Extract).where(workflow_id: params[:workflow_id], subject_id: params[:subject_id])
    render json: extracts
  end

  def update
    extract = Extract.find_or_initialize_by(workflow_id: workflow.id,
                                            extractor_key: extractor.key,
                                            classification_id: classification_id)
    authorize extract

    if extract.data != extract_params[:data]
      Workflow.transaction do
        extract.subject_reduction.update_all expired: true
        extract.user_reduction.update_all expired: true
        extract.update! extract_params
      end

      ReduceWorker.perform_async(workflow.id, subject.id, user_id) if workflow.configured?

      workflow.webhooks.process(:updated_extraction, data) if workflow.subscribers?
    end

    render json: extract
  end

  private

  def workflow
    @workflow ||= policy_scope(Workflow).find(params[:workflow_id])
  end

  def extractor
    workflow.extractors.find_by(key: params[:extractor_key])
  end

  def subject
    @subject ||= Subject.find(params[:extract][:subject_id])
  end

  def classification_id
    params[:extract][:classification_id]
  end

  def user_id
    params[:extract][:user_id]
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
