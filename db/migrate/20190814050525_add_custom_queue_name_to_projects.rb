class AddCustomQueueNameToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :custom_queue_name, :string
  end
end
