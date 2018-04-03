class CreateJoinTableExtractsUserReductions < ActiveRecord::Migration[5.1]
  def change
    create_join_table :extracts, :user_reductions do |t|
      # t.index [:extract_id, :user_reduction_id]
      # t.index [:user_reduction_id, :extract_id]
    end

    add_foreign_key "extracts_user_reductions", "extracts", on_delete: :cascade
    add_foreign_key "extracts_user_reductions", "user_reductions", on_delete: :cascade
  end
end
