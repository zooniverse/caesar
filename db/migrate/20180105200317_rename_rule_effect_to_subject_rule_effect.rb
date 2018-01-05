class RenameRuleEffectToSubjectRuleEffect < ActiveRecord::Migration[5.1]
  def change
    remove_index :rule_effects, :subject_rule_id
    remove_foreign_key "rule_effects", "subject_rules"

    rename_table :rule_effects, :subject_rule_effects

    # rename_column :rule_effects, :rule_id, :subject_rule_id
    add_index :subject_rule_effects, :subject_rule_id
    add_foreign_key "subject_rule_effects", "subject_rules"
  end
end
