class RemoveRulesAppliedFromProjects < ActiveRecord::Migration[5.2]
  def change
    remove_column :projects, :rules_applied
  end
end
