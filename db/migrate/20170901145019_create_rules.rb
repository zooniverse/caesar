class CreateRules < ActiveRecord::Migration[5.1]
  def change
    create_table :rules do |t|
      t.references :workflow, null: false, index: true, foreign_key: true
      t.jsonb :condition, null: false

      t.timestamps
    end
  end
end
