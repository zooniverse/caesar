class UniqueUserReductionIndex < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    remove_index :user_reductions, name: "index_user_reductions_covering"

    add_index :user_reductions,
      [:reducible_id, :reducible_type, :user_id, :reducer_key, :subgroup],
      name: "index_user_reductions_covering",
      unique: true,
      algorithm: :concurrently

    add_index :user_reductions,
      [:reducible_id, :reducible_type, :user_id],
      name: "index_user_reductions_on_reducible_and_user",
      algorithm: :concurrently
  end
end
