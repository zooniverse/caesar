class ExtractorsController < ApplicationController
  responders :flash
  rescue_from Extractor::UnknownTypeError, with: :record_not_valid

  def index
    authorize workflow

    respond_to do |format|
      format.html { redirect_to workflow }
      format.json { render json: workflow.extractors }
    end
  end

  def show
    authorize workflow
    @extractor = workflow.extractors.find(params[:id])
    respond_with @extractor
  end

  def new
    authorize workflow, :edit?
    @extractor = Extractor.of_type(params[:type]).new(workflow: workflow)
  end

  def edit
    authorize workflow
    @extractor = workflow.extractors.find(params[:id])
  end

  def create
    authorize workflow, :edit?

    extractor_class = Extractor.of_type(params[:extractor][:type])
    @extractor = extractor_class.new(extractor_params(extractor_class))

    respond_to do |format|
      if @extractor.save
        format.json { render json: @extractor }
      else
        format.json { render json: json_error_messages(@extractor.errors), status: :unprocessable_entity }
      end
      format.html { respond_with @extractor, location: workflow_path(workflow, anchor: 'extractors') }
    end
  end

  def update
    authorize workflow

    @extractor = workflow.extractors.find(params[:id])
    @extractor.update(extractor_params(@extractor.class))

    respond_to do |format|
      format.html { respond_with @extractor, location: workflow_path(workflow, anchor: 'extractors') }
      format.json { respond_with @extractor }
    end
  end

  def destroy
    authorize workflow, :edit?
    extractor = workflow.extractors.find(params[:id])

    extractor.destroy
    respond_to do |format|
      format.html { respond_with extractor, location: workflow_path(workflow, anchor: 'extractors') }
      format.json { respond_with extractor }
    end
  end

  private

  def workflow
    @workflow ||= policy_scope(Workflow).find(params[:workflow_id])
  end

  def extractor_params(klass)
    params.require(:extractor).permit(
      :key,
      :minimum_workflow_version,
      *klass.configuration_fields.keys,
      config: {},
    ).merge(workflow_id: workflow.id)
  end

  def record_not_valid(exception)
    render json: { error: exception.message }, status: 422
  end
end
