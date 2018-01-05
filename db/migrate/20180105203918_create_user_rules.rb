class CreateUserRules < ActiveRecord::Migration[5.1]
  def change
    create_table :user_rules do |t|
      t.jsonb :condition
      t.references :workflow, null: false, index: true, foreign_key: true

      t.timestamps
    end
  end
end
