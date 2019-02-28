class AddUserRulesCountToWorkflows < ActiveRecord::Migration[5.2]
  def change
    add_column :workflows, :user_rules_count, :int
  end
end
