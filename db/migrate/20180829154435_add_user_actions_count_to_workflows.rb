class AddUserActionsCountToWorkflows < ActiveRecord::Migration[5.1]
  def change
    add_column :workflows, :user_actions_count, :int
  end
end
