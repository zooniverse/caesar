class AddSubjectActionsCountToWorkflows < ActiveRecord::Migration[5.1]
  def change
    add_column :workflows, :subject_actions_count, :int
  end
end
