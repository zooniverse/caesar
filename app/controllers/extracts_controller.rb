class ExtractsController < ApplicationController
  def index
    extracts = policy_scope(Extract).where(workflow_id: params[:workflow_id], subject_id: params[:subject_id])
    render json: extracts
  end

  def import
    authorize workflow
    file_path = params[:file]
    workflow_id = params[:workflow_id]
    puts "HELLO WORLD"
    # workflow_id = params[:workflow_id]
    CreateExtractsWorker.perform_async(file_path, workflow_id)
    puts workflow
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
