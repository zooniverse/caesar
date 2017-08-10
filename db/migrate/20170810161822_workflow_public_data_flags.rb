class WorkflowPublicDataFlags < ActiveRecord::Migration[5.1]
  def change
    add_column :workflows, :public_extracts, :boolean, null: false, default: false
    add_column :workflows, :public_reductions, :boolean, null: false, default: false
  end
end
