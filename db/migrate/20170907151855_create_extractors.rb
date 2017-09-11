class CreateExtractors < ActiveRecord::Migration[5.1]
  def change
    create_table :extractors do |t|
      t.references :workflow, foreign_key: true, null: false
      t.string :key, null: false
      t.string :type, null: false
      t.jsonb :config, null: false, default: {}
      t.string :minimum_workflow_version

      t.timestamps
    end

    add_index :extractors, [:workflow_id, :key], unique: true
  end
end
