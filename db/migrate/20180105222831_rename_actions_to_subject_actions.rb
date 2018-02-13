class RenameActionsToSubjectActions < ActiveRecord::Migration[5.1]
  def change
    rename_table :actions, :subject_actions
  end
end
