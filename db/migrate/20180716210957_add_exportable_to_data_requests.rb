class AddExportableToDataRequests < ActiveRecord::Migration[5.1]
  def change
    add_column :data_requests, :exportable_id, :integer
    add_column :data_requests, :exportable_type, :string
  end
end
