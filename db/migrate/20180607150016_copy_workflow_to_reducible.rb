class CopyWorkflowToReducible < ActiveRecord::Migration[5.1]
  def change
    Reducer.in_batches.update_all("reducible_id=workflow_id, reducible_type='workflow'")
    UserReduction.in_batches.update_all("reducible_id=workflow_id, reducible_type='workflow'")
    SubjectReduction.in_batches.update_all("reducible_id=workflow_id, reducible_type='workflow'")
  end
end
