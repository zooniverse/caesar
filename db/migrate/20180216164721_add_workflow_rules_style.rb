class AddWorkflowRulesStyle < ActiveRecord::Migration[5.1]
  def change
    add_column :workflows, :rules_applied, :integer, null: false, default: 0
  end
end
