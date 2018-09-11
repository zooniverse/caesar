class FixReductionsIndexes < ActiveRecord::Migration[5.1]
  def change
    if index_exists?(:subject_reductions, ["workflow_id", "updated_at"], name: "subject_reductions_updated_by_workflow")
      remove_index :subject_reductions, name: "subject_reductions_updated_by_workflow"
    end

    if index_exists?(:user_reductions, ["workflow_id", "updated_at"], name: "user_reductions_updated_by_workflow")
      remove_index :user_reductions, name: "user_reductions_updated_by_workflow"
    end

    unless index_exists?(:subject_reductions, ["reducible_id", "reducible_type", "updated_at"], name: "subject_reductions_recency")
      add_index :subject_reductions, ["reducible_id", "reducible_type", "updated_at"], name: "subject_reductions_recency"
    end

    unless index_exists?(:user_reductions, ["reducible_id", "reducible_type", "updated_at"], name: "user_reductions_recency")
      add_index :user_reductions, ["reducible_id", "reducible_type", "updated_at"], name: "user_reductions_recency"
    end
  end
end
