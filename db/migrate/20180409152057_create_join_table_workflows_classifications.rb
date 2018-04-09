class CreateJoinTableWorkflowsClassifications < ActiveRecord::Migration[5.1]
  def change
    create_join_table :workflows, :classifications, table_name: :pending_classifications do |t|
      t.index :workflow_id
      t.index :classification_id
    end
  end
end
