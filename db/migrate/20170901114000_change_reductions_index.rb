class ChangeReductionsIndex < ActiveRecord::Migration[5.1]
  def change
    remove_index :reductions, name: :index_reductions_on_workflow_id_and_subject_id_and_reducer_key
    add_index :reductions, [:workflow_id, :subject_id]
    add_index :reductions,
      ["workflow_id", "subject_id", "reducer_key", "subgroup"],
      name: "index_reductions_covering",
      unique: true
    add_index :reductions,
      ["workflow_id", "subgroup"],
      name: "index_reductions_workflow_id_and_subgroup"
  end
end
