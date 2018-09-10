class AddSubjectReductionsCountToWorkflows < ActiveRecord::Migration[5.1]
  def change
    add_column :workflows, :subject_reductions_count, :int
  end
end
