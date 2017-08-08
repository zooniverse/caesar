class WorkflowsProjectIdNotNull < ActiveRecord::Migration[5.1]
  def change
    change_column_null :workflows, :project_id, false
  end
end
