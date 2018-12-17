class AddProjectIdIndexToExtracts < ActiveRecord::Migration[5.2]
  def change
    add_index :extracts, :project_id
  end
end
