class CreateProjects < ActiveRecord::Migration[5.1]
  def change
    create_table :projects do |t|
      t.jsonb :reducers_config
      t.jsonb :rules_config
      t.jsonb :webhooks, null: true
      t.integer :rules_applied, null: false, default: 0

      t.boolean "public_reductions", default: false, null: false

      t.timestamps
    end

    add_column :extracts, :project_id, :integer, index: true

    remove_foreign_key :subject_reductions, :workflows
    remove_foreign_key :reducers, :workflows
    remove_foreign_key :data_requests, :workflows
  end
end
