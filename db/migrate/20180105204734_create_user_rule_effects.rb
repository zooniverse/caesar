class CreateUserRuleEffects < ActiveRecord::Migration[5.1]
  def change
    create_table :user_rule_effects do |t|
      t.integer :action
      t.jsonb :config
      t.references :user_rule, null: false, index: true, foreign_key: true

      t.timestamps
    end
  end
end
