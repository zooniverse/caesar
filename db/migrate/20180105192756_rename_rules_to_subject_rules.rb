class RenameRulesToSubjectRules < ActiveRecord::Migration[5.1]
  def change
    remove_index :rule_effects, :rule_id
    remove_foreign_key "rule_effects", "rules"

    rename_table :rules, :subject_rules

    rename_column :rule_effects, :rule_id, :subject_rule_id
    add_index :rule_effects, :subject_rule_id
    add_foreign_key "rule_effects", "subject_rules"
  end
end
