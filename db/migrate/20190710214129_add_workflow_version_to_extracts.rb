class AddWorkflowVersionToExtracts < ActiveRecord::Migration[5.2]
  def change
    add_column :extracts, :workflow_version, :string
  end
end
