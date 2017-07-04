class CreateUserProfiles < ActiveRecord::Migration[5.1]
  def change
    create_table :user_profiles do |t|
      t.integer :project_id, null: false
      t.integer :workflow_id, null: false
      t.integer :user_id, null: false
      t.string :generator, null: false
      t.datetime :as_of, null: false
      t.jsonb :data, null: false, defualt: {}

      t.timestamps

      t.index [:workflow_id, :user_id]
    end
  end
end
