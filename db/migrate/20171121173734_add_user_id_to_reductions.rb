class AddUserIdToReductions < ActiveRecord::Migration[5.1]
  def change
    add_column :reductions, :user_id, :integer

    remove_index :reductions, name: :index_reductions_covering

    add_index :reductions,
      ["workflow_id", "subject_id", "reducer_key", "subgroup"],
      name: "index_reductions_subject_covering"
    add_index :reductions,
      ["workflow_id", "user_id", "reducer_key", "subgroup"],
      name: "index_reductions_user_covering"
  end
end
