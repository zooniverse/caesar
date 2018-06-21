class ReducersController < ApplicationController
  def index
    authorize workflow

    respond_to do |format|
      format.html { redirect_to workflow }
      format.json { render json: workflow.reducers }
    end
  end

  def show
    authorize workflow
    @reducer = workflow.reducers.find(params[:id])
    respond_with @reducer
  end

  def new
    authorize workflow
    @reducer = Reducer.of_type(params[:type]).new(reducible: workflow)
  end

  def edit
    authorize workflow
    @reducer = workflow.reducers.find(params[:id])
  end

  def create
    authorize workflow

    reducer_class = Reducer.of_type(params[:reducer][:type])
    @reducer = reducer_class.new(reducer_params(reducer_class))

    if(@reducer.filters['from'].blank? && @reducer.filters['to'].blank? && @reducer.filters['extractor_keys'].blank?)
      @reducer.filters = {}
    end

    if(@reducer.grouping['field_name'].blank?)
      @reducer.grouping = {}
    end
    
    if @reducer.save
      flash[:success] = 'Reducer created'
    else
      flash[:error] = 'Could not create reducer'
    end

    respond_with @reducer, location: [workflow]
  end

  def update
    authorize workflow
    @reducer = workflow.reducers.find(params[:id])

    if @reducer.update(reducer_params(@reducer.class))
      respond_to do |format|
        format.html { redirect_to workflow, success: 'Reducer created' }
        format.json { respond_with @reducer }
      end
    else
      respond_with @reducer
    end
  end

  def destroy
    authorize workflow
    reducer = workflow.reducers.find(params[:id])

    if reducer.destroy
      flash[:success] = 'Reducer deleted'
    else
      flash[:error] = 'Could not delete reducer'
    end

    respond_with reducer, location: [workflow]
  end

  private

  def workflow
    @workflow ||= policy_scope(Workflow).find(params[:workflow_id])
  end

  def reducer_params(klass)
    params.require(:reducer).permit(
      :key,
      :topic,
      *klass.configuration_fields.keys,
      filters: {},
      grouping: {},
    ).merge(reducible_id: workflow.id, reducible_type: "Workflow")
  end
end
