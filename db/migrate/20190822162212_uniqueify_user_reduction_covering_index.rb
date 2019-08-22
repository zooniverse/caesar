class UniqueifyUserReductionCoveringIndex < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    unless index_exists?(:user_reductions, [:reducible_id, :reducible_type, :user_id, :reducer_key, :subgroup])
      add_index :user_reductions,
        [:reducible_id, :reducible_type, :user_id, :reducer_key, :subgroup],
        name: "index_user_reductions_covering",
        unique: true,
        algorithm: :concurrently
    end
  end
end
