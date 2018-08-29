class AddSubjectReductionsCountToProjects < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :subject_reductions_count, :int
  end
end
