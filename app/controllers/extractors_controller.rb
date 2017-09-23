class ExtractorsController < ApplicationController
  def new
    authorize workflow
    @extractor = Extractor.of_type(params[:type]).new(workflow: workflow)
  end

  def create
    authorize workflow
    @extractor = Extractor.of_type(params[:extractor][:type]).new(extractor_params)

    if @extractor.save
      redirect_to workflow, success: 'Extractor created'
    else
      render action: :new
    end
  end

  def edit
    authorize workflow
    @extractor = workflow.extractors.find(params[:id])
  end

  def update
    authorize workflow
    @extractor = workflow.extractors.find(params[:id])

    if @extractor.update(extractor_params)
      redirect_to workflow, success: 'Extractor created'
    else
      render action: :update
    end
  end

  def destroy
    authorize workflow

    if workflow.extractors.find(params[:id]).destroy
      redirect_to workflow, success: 'Extractor deleted'
    else
      redirect_to workflow, error: 'Could not delete extractor'
    end
  end

  private

  def workflow
    @workflow ||= policy_scope(Workflow).find(params[:workflow_id])
  end

  def extractor_params
    params.require(:extractor).permit(
      :key,
      :minimum_workflow_version,
      config: {},
    ).merge(workflow_id: workflow.id)
  end
end
