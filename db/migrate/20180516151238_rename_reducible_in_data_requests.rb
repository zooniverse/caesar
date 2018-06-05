class RenameReducibleInDataRequests < ActiveRecord::Migration[5.1]
  def change
    rename_column :data_requests, :reducible_id, :exportable_id
    rename_column :data_requests, :reducible_type, :exportable_type
  end
end
