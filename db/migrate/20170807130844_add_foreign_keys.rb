class AddForeignKeys < ActiveRecord::Migration[5.1]
  def change
    remove_column :extracts, :project_id
    remove_column :reductions, :project_id

    change_column_null :extracts, :classification_id, false
    change_column_null :extracts, :classification_at, false
    change_column_null :extracts, :workflow_id, false
    change_column_null :extracts, :subject_id, false

    change_column_null :reductions, :workflow_id, false
    change_column_null :reductions, :subject_id, false

    add_foreign_key :extracts, :workflows
    add_foreign_key :extracts, :subjects

    add_foreign_key :reductions, :workflows
    add_foreign_key :reductions, :subjects

  end
end
