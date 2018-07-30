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

    begin
      @reducer.save!
      flash[:success] = 'Reducer created'
      respond_to do |format|
        format.html { redirect_to workflow_path(workflow, anchor: 'reducers') }
        format.json { respond_with @reducer }
      end
    rescue
      flash[:error] = 'Could not create reducer'
      respond_with @reducer
    end
  end

  def update
    authorize workflow
    @reducer = workflow.reducers.find(params[:id])

    begin
      @reducer.update!(reducer_params(@reducer.class))
      flash[:success] = 'Reducer updated'
      respond_to do |format|
        format.html { redirect_to workflow_path(workflow, anchor: 'reducers') }
        format.json { respond_with @reducer }
      end
    rescue
      flash.now[:error] = 'Failed to update reducer'
      respond_with @reducer
    end
  end

  def destroy
    authorize workflow
    reducer = workflow.reducers.find(params[:id])

    begin
      reducer.destroy!
      flash[:success] = 'Reducer deleted'
      respond_to do |format|
        format.html { redirect_to workflow_path(workflow, anchor: 'reducers') }
        format.json { respond_with reducer }
      end
    rescue
      flash.now[:error] = 'Could not delete reducer'
      respond_with reducer, location: workflow_path(workflow, anchor: 'reducers')
    end
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
