class ReducersController < ApplicationController
  def new
    authorize workflow
    @reducer = Reducer.of_type(params[:type]).new(workflow: workflow)
  end

  def create
    authorize workflow

    reducer_class = Reducer.of_type(params[:reducer][:type])
    @reducer = reducer_class.new(reducer_params(reducer_class))

    if @reducer.save
      redirect_to workflow, success: 'Reducer created'
    else
      render action: :new
    end
  end

  def edit
    authorize workflow
    @reducer = workflow.reducers.find(params[:id])
  end

  def update
    authorize workflow
    @reducer = workflow.reducers.find(params[:id])

    if @reducer.update(reducer_params(@reducer.class))
      redirect_to workflow, success: 'Reducer created'
    else
      render action: :edit
    end
  end

  def destroy
    authorize workflow

    if workflow.reducers.find(params[:id]).destroy
      redirect_to workflow, success: 'Reducer deleted'
    else
      redirect_to workflow, error: 'Could not delete reducer'
    end
  end

  private

  def workflow
    @workflow ||= policy_scope(Workflow).find(params[:workflow_id])
  end

  def reducer_params(klass)
    params.require(:reducer).permit(
      :key,
      :grouping,
      *klass.configuration_fields.keys,
      filters: {},
    ).merge(workflow_id: workflow.id)
  end
end
