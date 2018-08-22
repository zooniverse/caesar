class ReworkReductionIndexes < ActiveRecord::Migration[5.1]
  def up
    if index_exists?(:subject_reductions, ["workflow_id", "subject_id", "reducer_key", "subgroup"], name: "index_reductions_covering")
      remove_index :subject_reductions, name: "index_reductions_covering"
    end

    if index_exists?(:subject_reductions, ["workflow_id", "subject_id", "reducer_key", "subgroup"], name: "index_reductions_subject_covering")
      remove_index :subject_reductions, name: "index_reductions_subject_covering"
    end

    add_index :subject_reductions, ["reducible_type", "reducible_id", "subject_id", "reducer_key", "subgroup"], name: "index_subject_reductions_covering", unique: true
  end

  def down
    remove_index :subject_reductions, name: "index_subject_reductions_covering"
  end
end
