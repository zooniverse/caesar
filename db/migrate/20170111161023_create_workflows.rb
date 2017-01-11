class CreateWorkflows < ActiveRecord::Migration[5.0]
  def change
    create_table :workflows do |t|
      t.integer :project_id
      t.jsonb :rules

      t.timestamps
    end
  end
end
