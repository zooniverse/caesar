class CreateExtracts < ActiveRecord::Migration[5.0]
  def change
    create_table :extracts do |t|
      t.integer :classification_id
      t.timestamp :classification_at
      t.integer :extractor_id
      t.integer :project_id
      t.integer :workflow_id
      t.integer :user_id
      t.integer :subject_id
      t.jsonb :data

      t.timestamps
    end

    add_index :extracts, [:classification_id, :extractor_id], unique: true
    add_index :extracts, :workflow_id
    add_index :extracts, :user_id
    add_index :extracts, :subject_id
  end
end
