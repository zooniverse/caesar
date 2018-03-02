class AddColumnsToSubjectReductions < ActiveRecord::Migration[5.1]
  def change
    add_column :subject_reductions, :lock_version, :int, default: 0, null: false
    add_column :subject_reductions, :store, :jsonb
  end
end
