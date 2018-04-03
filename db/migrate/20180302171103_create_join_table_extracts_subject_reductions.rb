class CreateJoinTableExtractsSubjectReductions < ActiveRecord::Migration[5.1]
  def change
    create_join_table :extracts, :subject_reductions do |t|
      # t.index [:extract_id, :subject_reduction_id]
      # t.index [:subject_reduction_id, :extract_id]
    end

    add_foreign_key "extracts_subject_reductions", "extracts", on_delete: :cascade
    add_foreign_key "extracts_subject_reductions", "subject_reductions", on_delete: :cascade
  end
end
