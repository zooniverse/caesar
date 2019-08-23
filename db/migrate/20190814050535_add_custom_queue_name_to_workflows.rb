class AddCustomQueueNameToWorkflows < ActiveRecord::Migration[5.2]
  def change
    add_column :workflows, :custom_queue_name, :string
  end
end
