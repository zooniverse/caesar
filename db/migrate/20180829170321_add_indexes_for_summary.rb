class AddIndexesForSummary < ActiveRecord::Migration[5.1]
  def up
    unless index_exists?(:extracts, ["workflow_id", "updated_at"], name: "extracts_updated_by_workflow")
      add_index :extracts, ["workflow_id", "updated_at"], name: "extracts_updated_by_workflow"
    end

    unless index_exists?(:subject_reductions, ["workflow_id", "updated_at"], name: "subject_reductions_updated_by_workflow")
      add_index :subject_reductions, ["workflow_id", "updated_at"], name: "subject_reductions_updated_by_workflow"
    end

    unless index_exists?(:user_reductions, ["workflow_id", "updated_at"], name: "user_reductions_updated_by_workflow")
      add_index :user_reductions, ["workflow_id", "updated_at"], name: "user_reductions_updated_by_workflow"
    end

    unless index_exists?(:subject_actions, ["workflow_id", "updated_at"], name: "subject_actions_updated_by_workflow")
      add_index :subject_actions, ["workflow_id", "updated_at"], name: "subject_actions_updated_by_workflow"
    end

    unless index_exists?(:user_actions, ["workflow_id", "updated_at"], name: "user_actions_updated_by_workflow")
      add_index :user_actions, ["workflow_id", "updated_at"], name: "user_actions_updated_by_workflow"
    end

  end

  def down
    if index_exists?(:extracts, ["workflow_id", "updated_at"], name: "extracts_updated_by_workflow")
      remove_index :extracts, name: "extracts_updated_by_workflow"
    end

    if index_exists?(:subject_reductions, ["workflow_id", "updated_at"], name: "subject_reductions_updated_by_workflow")
      remove_index :subject_reductions, name: "subject_reductions_updated_by_workflow"
    end

    if index_exists?(:user_reductions, ["workflow_id", "updated_at"], name: "user_reductions_updated_by_workflow")
      remove_index :user_reductions, name: "user_reductions_updated_by_workflow"
    end

    if index_exists?(:subject_actions, ["workflow_id", "updated_at"], name: "subject_actions_updated_by_workflow")
      remove_index :subject_actions, name: "subject_actions_updated_by_workflow"
    end

    if index_exists?(:user_actions, ["workflow_id", "updated_at"], name: "user_actions_updated_by_workflow")
      remove_index :user_actions, name: "user_actions_updated_by_workflow"
    end
  end
end
