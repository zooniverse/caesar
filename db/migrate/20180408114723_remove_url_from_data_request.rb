class RemoveUrlFromDataRequest < ActiveRecord::Migration[5.1]
  def change
    remove_column :data_requests, :url, :string
  end
end
