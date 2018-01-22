class RenameReductionsToSubjectReductions < ActiveRecord::Migration[5.1]
  def change
    rename_table :reductions, :subject_reductions
  end
end
