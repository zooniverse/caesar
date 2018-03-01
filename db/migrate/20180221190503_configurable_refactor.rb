class ConfigurableRefactor < ActiveRecord::Migration[5.1]
  def change
    create_table :projects do |t|

      t.jsonb :reducers_config
      t.jsonb :extractors_config
      t.jsonb :rules_config
      t.jsonb :webhooks, null: true

      t.boolean "public_extracts", default: false, null: false
      t.boolean "public_reductions", default: false, null: false

      t.timestamps
    end

    rename_column :extractors, :workflow_id, :configurable_id
    rename_column :reducers, :workflow_id, :configurable_id
    rename_column :extracts, :workflow_id, :configurable_id
    rename_column :data_requests, :workflow_id, :configurable_id
    add_column :classifications, :configurable_id, :integer

    add_column :extractors, :configurable_type, :string
    add_column :reducers, :configurable_type, :string
    add_column :extracts, :configurable_type, :string
    add_column :data_requests, :configurable_type, :string
    add_column :classifications, :configurable_type, :string

  end
end
