class CreateUserReductions < ActiveRecord::Migration[5.1]
  def change
    create_table :user_reductions do |t|
      t.string :reducer_key
      t.integer :workflow_id, null: false
      t.integer :user_id, null: false
      t.jsonb :data
      t.string :subgroup, default: "_default", null: false

      t.timestamps
    end

    add_index :user_reductions, :workflow_id
    add_index :user_reductions, [:workflow_id, :user_id, :reducer_key, :subgroup], name: "index_user_reductions_covering"
    add_index :user_reductions, [:workflow_id, :user_id]
    add_index :user_reductions, :user_id
  end
end
