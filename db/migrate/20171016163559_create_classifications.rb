class CreateClassifications < ActiveRecord::Migration[5.1]
  def up
    create_table :classifications, id: :integer, default: nil do |t|
      t.integer :project_id, null: false
      t.integer :workflow_id, null: false
      t.integer :user_id
      t.integer :subject_id, null: false
      t.string :workflow_version, null: false

      t.jsonb :annotations, null: false, default: {}
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
      t.timestamp :received_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    end

    add_foreign_key :classifications, :workflows
    add_foreign_key :classifications, :subjects
  end

  def down
    drop_table :classifications
  end
end
