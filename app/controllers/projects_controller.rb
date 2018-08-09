class ProjectsController < ApplicationController
  responders :flash

  # GET /projects
  def index
    @projects = policy_scope(Project).all.sort_by(&:id)
    @project = Project.new
    respond_with @projects
  end

  # GET /projects/1
  def show
    authorize project
    respond_with project
  end

  # GET /projects/new
  def new
    skip_authorization

    @project = Project.new
    respond_with @project
  end

  # GET /projects/1/edit
  def edit
    authorize project
    respond_with project
  end

  # POST /projects
  def create
    skip_authorization

    project_id = params[:project][:id]

    unless credential.accessible_project?(project_id)
      head :forbidden
      return
    end

    if Rails.env.development? || Rails.env.test?
      panoptes_project = { id: project_id, display_name: 'New Project' }
    else
      panoptes_project = Effects.panoptes.project(project_id)
    end

    @project = Project.new(project_params.merge(
      id: project_id,
      display_name: panoptes_project['display_name']
    ))

    @project.save

    respond_to do |format|
      format.html { respond_with project, location: projects_path }
      format.json { respond_with project }
    end
  end

  # PATCH/PUT /projects/1
  def update
    authorize project
    project.update(project_params)
    respond_with project
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def project
    @project ||= policy_scope(Project).find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def project_params
    params.require(:project).permit(
      :display_name,
    )
  end
end
