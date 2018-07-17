class CreateProjects < ActiveRecord::Migration[5.1]
  def change
    create_table :projects do |t|
      t.jsonb :reducers_config
      t.jsonb :rules_config
      t.jsonb :webhooks, null: true

      t.boolean "public_reductions", default: false, null: false

      t.timestamps
    end
  end
end
