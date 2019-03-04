class RemoveWorkflowIdFromDataRequests < ActiveRecord::Migration[5.2]
  def change
    remove_index :data_requests, name: :look_up_existing
    remove_index :data_requests, name: :index_data_requests_on_workflow_id

    remove_column :data_requests, :workflow_id

    add_index :data_requests, [:exportable_id, :exportable_type]
    add_index :data_requests, [:user_id, :exportable_id, :exportable_type, :subgroup, :requested_data], name: :look_up_existing, unique: true
  end
end
