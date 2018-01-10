class CreateUserActions < ActiveRecord::Migration[5.1]
  def change
    create_table :user_actions do |t|
      t.references :workflow, null: false, index: true, foreign_key: true
      t.integer "user_id", null: false
      t.string "effect_type", null: false
      t.jsonb "config", default: {}, null: false
      t.integer "status", default: 0, null: false
      t.datetime "attempted_at"
      t.datetime "completed_at"
      t.integer "rule_id"
      t.index ["user_id"], name: "index_user_subject_actions_on_user_id"

      t.timestamps
    end
  end
end
