class ReducersController < ApplicationController
  responders :flash

  def index
    authorize reducible

    respond_to do |format|
      format.html { redirect_to reducible }
      format.json { render json: reducible.reducers }
    end
  end

  def show
    authorize reducible
    @reducer = reducible.reducers.find(params[:id])

    respond_with reducible, @reducer
  end

  def new
    authorize reducible
    reducible_type
    @reducer = Reducer.of_type(params[:type]).new(reducible: reducible)

    respond_with reducible, @reducer
  end

  def edit
    authorize reducible
    reducible_type
    @reducer = reducible.reducers.find(params[:id])

    respond_with reducible, @reducer
  end

  def create
    authorize reducible

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
      format.html { respond_with @reducer, location: redirect_path }
      format.json { respond_with @reducer }
    end
  end

  def update
    authorize reducible

    @reducer = reducible.reducers.find(params[:id])
    params = reducer_params(@reducer.class)

    if params.dig('filters','from').blank? && params.dig('filters','to').blank? && params.dig('filters','extractor_keys').blank?
      params['filters'] = {}
    end

    if params.dig('grouping','field_name').blank?
      params['grouping'] = {}
    end

    @reducer.update(params)

    respond_to do |format|
      format.html { respond_with @reducer, location: redirect_path }
      format.json { respond_with @reducer }
    end
  end

  def destroy
    authorize reducible

    reducer = reducible.reducers.find(params[:id])
    reducer.destroy

    respond_to do |format|
      format.html { respond_with reducer, location: redirect_path }
      format.json { respond_with reducer }
    end
  end

  private

  def reducible
    @reducible ||= ( workflow || project )
  end

  def reducible_type
    @reducible_type ||= :Workflow if params.key? :workflow_id
    @reducible_type ||= :Project if params.key? :project_id

    @reducible_type
  end

  def redirect_path
    return workflow_path(workflow, anchor: 'reducers') if reducible_type == :Workflow
    return project_path(project, anchor: 'reducers') if reducible_type == :Project
  end

  def workflow
    @workflow ||= policy_scope(Workflow).find(params[:workflow_id]) if params.key? :workflow_id
  end

  def project
    @project ||= policy_scope(Project).find(params[:project_id]) if params.key? :project_id
  end

  def reducer_params(klass)
    params.require(:reducer).permit(
      :key,
      :topic,
      *klass.configuration_fields.keys,
      filters: {},
      grouping: {},
    ).merge(reducible_id: reducible.id, reducible_type: reducible_type)
  end
end
