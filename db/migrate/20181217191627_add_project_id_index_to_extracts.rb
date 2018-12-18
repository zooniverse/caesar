class AddProjectIdIndexToExtracts < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :extracts, :project_id, algorithm: :concurrently
  end
end
