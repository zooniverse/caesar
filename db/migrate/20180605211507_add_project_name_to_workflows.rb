class AddProjectNameToWorkflows < ActiveRecord::Migration[5.1]
  def change
    add_column :workflows, :project_name, :string
  end
end
