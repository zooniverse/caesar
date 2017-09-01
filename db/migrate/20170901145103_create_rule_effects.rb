class CreateRuleEffects < ActiveRecord::Migration[5.1]
  def change
    create_table :rule_effects do |t|
      t.references :rule, null: false, index: true, foreign_key: true
      t.integer :action, null: false
      t.jsonb :config, null: false, default: {}

      t.timestamps
    end
  end
end
