class ConfigurableRefactor < ActiveRecord::Migration[5.1]
  def change
    create_table :projects do |t|

      t.jsonb :reducers_config
      t.jsonb :rules_config
      t.jsonb :webhooks, null: true

      t.boolean "public_reductions", default: false, null: false

      t.timestamps
    end

    rename_column :reducers, :workflow_id, :reducible_id
    rename_column :user_reductions, :workflow_id, :reducible_id
    rename_column :subject_reductions, :workflow_id, :reducible_id
    rename_column :data_requests, :workflow_id, :reducible_id

    add_column :reducers, :reducible_type, :string
    add_column :user_reductions, :reducible_type, :string
    add_column :subject_reductions, :reducible_type, :string
    add_column :data_requests, :reducible_type, :string

  end
end
