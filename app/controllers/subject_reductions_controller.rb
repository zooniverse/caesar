class SubjectReductionsController < ApplicationController
  def index
    reductions = policy_scope(SubjectReduction).where(reducible_id: params[:reducible_id], subject_id: params[:subject_id])
    reductions = reductions.where(reducer_key: params[:reducer_key]) if params.key?(:reducer_key)

    render json: reductions
  end

  def update
    reduction = SubjectReduction.find_or_initialize_by(reducible_id: reducible.id,
                                                reducer_key: reducer.key,
                                                subject_id: subject.id,
                                                subgroup: subgroup)
    authorize reduction
    reduction.update! reduction_params

    CheckRulesWorker.perform_async(workflow.id, subject.id) if workflow.configured?

    workflow.webhooks.process(:updated_reduction, data) if workflow.subscribers?

    render json: reduction
  end

  private

  def reducible
    @reducible ||=  if params[:workflow_id]
                      policy_scope(Workflow).find(params[:workflow_id])
                    elsif params[:project]
                      policy_scope(Project).find(params[:project_id])
                    end
  end

  def reducible_type
    @reducible_type ||=   if params[:workflow_id]
                            "workflow"
                          elsif params[:project]
                            "project"
                          end
  end

  def data
    params[:reduction][:data]
  end

  def subgroup
    params[:reduction][:subgroup] || :_default
  end

  def reducer
    workflow.reducers.find_by!(key: params[:reducer_key])
  end

  def subject
    @subject ||= Subject.find(params[:reduction][:subject_id])
  end

  def reduction_params
    params.require(:reduction).permit(:data).tap do |whitelisted|
      whitelisted[:data] = params[:reduction][:data].permit!
    end
  end
end
