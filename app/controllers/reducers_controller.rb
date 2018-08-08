class ReducersController < ApplicationController
  responders :flash

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

    respond_with workflow, @reducer
  end

  def new
    authorize workflow
    @reducer = Reducer.of_type(params[:type]).new(reducible: workflow)

    respond_with workflow, @reducer
  end

  def edit
    authorize workflow
    @reducer = workflow.reducers.find(params[:id])

    respond_with workflow, @reducer
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

    @reducer.save

    respond_to do |format|
      format.html { respond_with @reducer, location: workflow_path(workflow, anchor: 'reducers') }
      format.json { respond_with @reducer }
    end
  end

  def update
    authorize workflow

    @reducer = workflow.reducers.find(params[:id])
    params = reducer_params(@reducer.class)

    # if(params['filters']['from'].blank? && params['filters']['to'].blank? && params['filters']['extractor_keys'].blank?)
    if(params.dig('filters','from').blank? && params.dig('filters','to').blank? && params.dig('filters','extractor_keys').blank?)
      params['filters'] = {}
    end

    # if(params['grouping']['field_name'].blank?)
    if(params.dig('grouping','field_name').blank?)
      params['grouping'] = {}
    end

    @reducer.update(params)

    respond_to do |format|
      format.html { respond_with @reducer, location: workflow_path(workflow, anchor: 'reducers') }
      format.json { respond_with @reducer }
    end
  end

  def destroy
    authorize workflow

    reducer = workflow.reducers.find(params[:id])
    reducer.destroy

    respond_to do |format|
      format.html { respond_with reducer, location: workflow_path(workflow, anchor: 'reducers') }
      format.json { respond_with reducer }
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
