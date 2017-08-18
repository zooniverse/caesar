class CreateDataRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :data_requests, id: :uuid do |t|
      t.integer :user_id
      t.references :workflow, null: false, foreign_key: true
      t.string :subgroup
      t.integer :requested_data
      t.string :url
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    add_index :data_requests, [:user_id, :workflow_id, :subgroup, :requested_data], unique: true, name: 'look_up_existing'
  end
end
