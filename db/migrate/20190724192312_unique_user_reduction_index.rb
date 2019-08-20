class UniqueUserReductionIndex < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change

    unless index_exists?(:user_reductions, [:reducible_id, :reducible_type, :user_id, :reducer_key, :subgroup]) do
      add_index :user_reductions,
        [:reducible_id, :reducible_type, :user_id, :reducer_key, :subgroup],
        name: "index_user_reductions_covering",
        unique: true,
        algorithm: :concurrently
    end

    add_index :user_reductions,
      [:reducible_id, :reducible_type, :user_id],
      name: "index_user_reductions_on_reducible_and_user",
      algorithm: :concurrently
  end
end
