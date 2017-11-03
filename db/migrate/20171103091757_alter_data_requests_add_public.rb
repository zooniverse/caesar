class AlterDataRequestsAddPublic < ActiveRecord::Migration[5.1]
  def change
    add_column :data_requests, :public, :boolean, null: false, default: false
  end
end
