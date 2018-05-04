class AddStatusToWorkflow < ActiveRecord::Migration[5.1]
  def change
    add_column :workflows, :status, :integer, null: false, default: 1
  end
end
