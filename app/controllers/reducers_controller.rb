class ReducersController < ApplicationController
  responders :flash
  rescue_from Reducer::UnknownTypeError, with: :record_not_valid

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
    authorize reducible, :edit?
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
    authorize reducible, :edit?
    reducer_class = Reducer.of_type(params[:reducer][:type])
    new_params = reducer_params(reducer_class)
    new_params.fetch('filters', {}).reject!{ |k, v| v.blank? }
    new_params.fetch('grouping', {}).reject!{ |k, v| v.blank? }

    filters = new_params.fetch('filters', {})
    if filters.has_key?('extractor_keys') && filters['extractor_keys'].is_a?(String)
      begin
        filters['extractor_keys'] = JSON.parse(filters['extractor_keys'])
      rescue JSON::ParserError, TypeError;
      end
    end

    @reducer = reducer_class.new(new_params)

    respond_to do |format|
      if @reducer.save
        format.json { render json: @reducer }
      else
        format.json { render json: json_error_messages(@reducer.errors), status: :unprocessable_entity }
      end
      format.html { respond_with @reducer, location: redirect_path }
    end
  end

  def update
    authorize reducible

    @reducer = reducible.reducers.find(params[:id])
    params = reducer_params(@reducer.class)

    params.fetch('filters', nil)&.reject!{ |k, v| v.blank? }
    params.fetch('grouping', nil)&.reject!{ |k, v| v.blank? }

    filters = params.fetch('filters', {})
    if filters.has_key?('extractor_keys') && filters['extractor_keys'].is_a?(String)
      begin
        filters['extractor_keys'] = JSON.parse(filters['extractor_keys'])
      rescue JSON::ParserError, TypeError;
      end
    end

    @reducer.update(params)

    respond_to do |format|
      format.html { respond_with @reducer, location: redirect_path }
      format.json { respond_with @reducer }
    end
  end

  def destroy
    authorize reducible, :edit?

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

  def record_not_valid(exception)
    render json: { error: exception.message }, status: 422
  end

end
