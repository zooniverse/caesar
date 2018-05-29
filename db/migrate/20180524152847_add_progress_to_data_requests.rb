class AddProgressToDataRequests < ActiveRecord::Migration[5.1]
  def change
    add_column :data_requests, :records_count, :integer
    add_column :data_requests, :records_exported, :integer
  end
end
