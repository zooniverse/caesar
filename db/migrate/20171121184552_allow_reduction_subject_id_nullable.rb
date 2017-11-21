class AllowReductionSubjectIdNullable < ActiveRecord::Migration[5.1]
  def change
    change_column_null :reductions, :subject_id, true
  end
end
