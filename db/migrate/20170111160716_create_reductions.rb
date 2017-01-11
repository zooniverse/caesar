class CreateReductions < ActiveRecord::Migration[5.0]
  def change
    create_table :reductions do |t|
      t.integer :reducer_id
      t.integer :project_id
      t.integer :workflow_id
      t.integer :subject_id
      t.jsonb :data

      t.timestamps
    end

    add_index :reductions, [:workflow_id, :subject_id, :reducer_id], unique: true
    add_index :reductions, :workflow_id
    add_index :reductions, :subject_id
  end
end
